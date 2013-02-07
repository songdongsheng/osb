#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#include "vm_metric.h"

static struct {
    char *host;
    char *port;
} udp_target_list [] = {
 /* {"192.168.30.211", "514"}, */
 /* {"192.168.30.233", "514"}, */
 /* {"192.168.18.37", "514"}, */
 /* {"192.168.18.38", "514"}, */
    {"192.168.18.74", "514"},
};

typedef struct {
    SOCKET *socket;
    int socket_count;
    unsigned int max_msg_size;
    unsigned int snd_buf_size;
} udp_contex;

static SOCKET setup_logger_socket(char *host, char *port)
{
    int rc;
    SOCKET s = INVALID_SOCKET;
    struct addrinfo hints;
    struct addrinfo *result, *rp;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;    /* Allow IPv4 or IPv6 */
    hints.ai_socktype = SOCK_DGRAM; /* Datagram socket */
    hints.ai_flags = 0;
    hints.ai_protocol = IPPROTO_UDP; /* UDP protocol */

    rc = getaddrinfo(host, port, &hints, &result);
    if (rc != 0) {
        log_message(LOG_ERR, 0, rc, "getaddrinfo failed");
        return INVALID_SOCKET;
    }

    for (rp = result; rp != NULL; rp = rp->ai_next) {
        s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (s == INVALID_SOCKET) {
            log_message(LOG_ERR, 0, WSAGetLastError(), "socket failed");
            continue;
        }

        if (connect(s, rp->ai_addr, rp->ai_addrlen) == -1)
            log_message(LOG_ERR, 0, WSAGetLastError(), "connect failed");
        else
            break;

        closesocket(s);
    }

    freeaddrinfo(result);

    return s;
}

int udp_target_init(struct target_contex **contex)
{
    int i, optlen;
    SOCKET s = INVALID_SOCKET;
    udp_contex *ctx = (udp_contex *) calloc(1, sizeof(udp_contex));

    *contex = (struct target_contex *) ctx;
    if (ctx == NULL) {
        return -1;
    }

    ctx->socket_count = sizeof(udp_target_list)/sizeof(udp_target_list[0]);
    ctx->socket = (SOCKET *) calloc(sizeof(udp_target_list)/sizeof(udp_target_list[0]), sizeof(SOCKET));
    if (ctx->socket == NULL) {
        log_message(LOG_ERR, errno, 0, "calloc failed");
        return -1;
    }

    for(i = 0, optlen = 0; i < sizeof(udp_target_list)/sizeof(udp_target_list[0]); i++) {
        if ((ctx->socket[i] = setup_logger_socket(udp_target_list[i].host, udp_target_list[i].port)) != INVALID_SOCKET) {
            optlen += 1;
            s = ctx->socket[i];
            log_message(LOG_INFO, 0, 0, "connect to udp://%s:%s success", udp_target_list[i].host, udp_target_list[i].port);
        } else {
            log_message(LOG_ERR, 0, WSAGetLastError(), "connect to udp://%s:%s failed", udp_target_list[i].host, udp_target_list[i].port);
        }
    }

    if (optlen < 1) {
        return -1;
    }

    optlen = sizeof(ctx->max_msg_size);
    if (getsockopt(s, SOL_SOCKET, SO_MAX_MSG_SIZE, (char *) (& ctx->max_msg_size), & optlen) != 0) {
        log_message(LOG_ERR, 0, WSAGetLastError(), "getsockopt on SO_MAX_MSG_SIZE failed");
        return -1;
    }

    optlen = sizeof(ctx->snd_buf_size);
    if (getsockopt(s, SOL_SOCKET, SO_SNDBUF, (char *) (& ctx->snd_buf_size), & optlen) != 0) {
        log_message(LOG_ERR, 0, WSAGetLastError(), "getsockopt on SO_SNDBUF failed");
        return -1;
    }

    log_message(LOG_INFO, 0, 0, "max_msg_size: %u, snd_buf_size: %u", ctx->max_msg_size, ctx->snd_buf_size);

    return 0;
}

int udp_target_save(struct target_contex *contex, metric_record *prev_record, metric_record *curr_record, int number)
{
    int i, n;
    udp_contex *ctx = (udp_contex *) contex;
    char buffer[METRIC_MAX_SIZE];
    if (number != METRIC_NUMBER)
        return -1;

    for(i = 0; i < number; i++) {
        int len;
        double value = curr_record[i].value;

        if (strcmp("ElapsedMs", curr_record[i].metric) == 0 ||
            strcmp("CpuUsedMs", curr_record[i].metric) == 0 ||
            strcmp("CpuStolenMs", curr_record[i].metric) == 0) {

                value -= prev_record[i].value;
        }

        len = _snprintf(buffer, METRIC_MAX_SIZE, "<190>DRE.METRIC:metric_record: {\"id\" : \"%s\", \"domain\" : \"%s\", \"host\" : \"%s\", \"metric\" : \"%s\", \"value\" : %lf, \"period\" : %d, \"unixtime\" : %I64d, \"isotime\" : \"%s\"}",
            curr_record[i].id, curr_record[i].domain, curr_record[i].host, curr_record[i].metric, value, curr_record[i].period,
            curr_record[i].unixtime, curr_record[i].isotime);
        if (len > 0 && len < METRIC_MAX_SIZE) {
            for(n = 0; n < ctx->socket_count; n++) {
                if(send(ctx->socket[n], buffer, len, 0) == -1) {
                    log_message(LOG_ERR, 0, WSAGetLastError(), "send to udp://%s:%s failed with text is:\n%s", udp_target_list[n].host, udp_target_list[n].port, buffer);
                }
            }
        } else {
            log_message(LOG_ERR, 0, 0, "message large than %d, the text is:\n%s", METRIC_MAX_SIZE, "<190>DRE.METRIC:metric_record: {\"id\" : \"%s\", \"domain\" : \"%s\", \"host\" : \"%s\", \"metric\" : \"%s\", \"value\" : %lf, \"period\" : %d, \"unixtime\" : %I64d, \"isotime\" : \"%s\"}\n",
                curr_record[i].id, curr_record[i].domain, curr_record[i].host, curr_record[i].metric, value, curr_record[i].period,
                curr_record[i].unixtime, curr_record[i].isotime);
            return -1;
        }
    }

    return 0;
}

int udp_target_fini(struct target_contex **ctx)
{
    if (ctx) {
        int n;
        udp_contex *t = (udp_contex *) *ctx;

        for(n = 0; n < t->socket_count; n++)
            closesocket(t->socket[n]);

        free(*ctx);
        *ctx = NULL;
    }

    return 0;
}

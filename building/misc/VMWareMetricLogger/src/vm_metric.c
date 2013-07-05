#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>
#include <rpc.h>

#include <vmGuestLib.h>

#include "vm_metric.h"
#include "message.h"

static void create_uuid(char *buffer)
{
    UUID uuid;

    UuidCreate(&uuid);

    /* f5e1881c-1837-11e2-9254-d3c51bac2aed */
    sprintf(buffer, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x", uuid.Data1, uuid.Data2, uuid.Data3,
        uuid.Data4[0], uuid.Data4[1], uuid.Data4[2], uuid.Data4[3], uuid.Data4[4], uuid.Data4[5],
        uuid.Data4[6], uuid.Data4[7]);
}

/* Number of 100ns-seconds between the beginning of the Windows epoch
* (Jan. 1, 1601) and the Unix epoch (Jan. 1, 1970)
*/
#define DELTA_EPOCH_IN_100NS    116444736000000000i64
#define POW10_7                 10000000

static double get_unixtime()
{
    union {
        unsigned __int64 u64;
        FILETIME ft;
    }  ct;

    GetSystemTimeAsFileTime(&ct.ft);

    return  (ct.u64 - DELTA_EPOCH_IN_100NS) / (double) POW10_7;
}

unsigned int get_remain_time_as_ms(unsigned int seconds)
{
    double t1 = get_unixtime();
    __int64 t2 = (__int64) ceil(t1);
    unsigned int remainder = (unsigned int) (t2 % seconds);
    unsigned int t;

    t2 += seconds - remainder;
    t = (unsigned int) ((t2 - t1) * 1000);

    return t;
}

/* 2012-10-11T11:20:25.092985177+0800 */
static void get_isotime(char *buffer)
{
    SYSTEMTIME st;
    TIME_ZONE_INFORMATION tzi;

    GetTimeZoneInformation(&tzi);
    GetLocalTime(&st);

    sprintf(buffer, "%04d-%02d-%02dT%02d:%02d:%02d.%03d%+03d00", st.wYear, st.wMonth, st.wDay,
        st.wHour, st.wMinute, st.wSecond, st.wMilliseconds, -tzi.Bias / 60);
}

static int read_metric_record(VMGuestLibHandle vmHandle, metric_record *record, int number)
{
    VMGuestLibError vmError;
    unsigned __int32 cpuShares = 0;
    unsigned __int64 elapsedMs = 0;
    unsigned __int64 cpuUsedMs = 0;
    unsigned __int64 cpuStolenMs = 0;
    unsigned __int32 memUsedMB = 0;
    unsigned __int32 memActiveMB = 0;
    unsigned __int32 memSwappedMB = 0;

    if (number != METRIC_NUMBER)
        return -1;

    /* cpuShares */
    vmError = VMGuestLib_GetCpuShares(vmHandle, &cpuShares);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetCpuShares failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    strcpy(record[0].metric, "CpuShares");
    record[0].value = cpuShares;

    /* ElapsedMs */
    vmError = VMGuestLib_GetElapsedMs(vmHandle, &elapsedMs);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetElapsedMs failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    strcpy(record[1].metric, "ElapsedMs");
    record[1].value = elapsedMs;

    /* CpuUsedMs */
    vmError = VMGuestLib_GetCpuUsedMs(vmHandle, &cpuUsedMs);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetCpuUsedMs failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    strcpy(record[2].metric, "CpuUsedMs");
    record[2].value = cpuUsedMs;

    /* CpuStolenMs */
    vmError = VMGuestLib_GetCpuStolenMs(vmHandle, &cpuStolenMs);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetCpuStolenMs failed: %s", VMGuestLib_GetErrorText(vmError));
        if (vmError == VMGUESTLIB_ERROR_UNSUPPORTED_VERSION) {
            cpuStolenMs = 0;
            log_message(LOG_WARNING, 0, 0, "Skipping CPU stolen");
        }
    }

    strcpy(record[3].metric, "CpuStolenMs");
    record[3].value = cpuStolenMs;

    /* MemUsedMB */
    vmError = VMGuestLib_GetMemUsedMB(vmHandle, &memUsedMB);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetMemUsedMB failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    strcpy(record[4].metric, "MemUsedMB");
    record[4].value = memUsedMB;

    /* MemActiveMB */
    vmError = VMGuestLib_GetMemActiveMB(vmHandle, &memActiveMB);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetMemActiveMB failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    strcpy(record[5].metric, "MemActiveMB");
    record[5].value = memActiveMB;

    /* MemSwappedMB */
    vmError = VMGuestLib_GetMemSwappedMB(vmHandle, &memSwappedMB);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetMemSwappedMB failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    strcpy(record[6].metric, "MemSwappedMB");
    record[6].value = memSwappedMB;

    return 0;
}

static int init_metric_record(metric_record *record, int number, char *domain, char *host)
{
    int i;
    __int64 unixtime;
    char isotime[34 + 1];

    if (number != METRIC_NUMBER)
        return -1;

    unixtime = (__int64) (get_unixtime() + 0.5);
    get_isotime(isotime);

    for(i = 0; i < 7; i++) {
        create_uuid(record[i].id);
        strcpy(record[i].domain, domain);
        strcpy(record[i].host, host);
        record[i].period = METRIC_PERIOD;
        record[i].unixtime = unixtime;
        strcpy(record[i].isotime, isotime);
    }

    return 0;
}

static char *get_host_name(char *buffer, int n)
{
    DWORD size = n;

    if (GetComputerNameExA(ComputerNamePhysicalDnsHostname, buffer, &size) == 0) {
        DWORD rc = GetLastError();
        if (rc == ERROR_MORE_DATA)
            log_message(LOG_ERR, 0, 0, "GetComputerNameExA expect %d bytes, but only give %d bytes", size, n);
        else
            log_message(LOG_ERR, 0, rc, "GetComputerNameExA failed");

        return NULL;
    }

    buffer[n - 1] = '\0';

    return buffer;
}

static target_action action[] = {
        {"udp", udp_target_init, udp_target_save, udp_target_fini, NULL, 0 },
     /* {"oci", oci_target_init, oci_target_save, oci_target_fini, NULL, 0 }, */
     /* {"odbc", odbc_target_init, odbc_target_save, odbc_target_fini, NULL, 0 }, */
        {NULL, NULL, NULL, NULL, 0}
};

int vmware_metric_init(metric_contex **contex, char *domain)
{
    int i, rc, n;
    VMGuestLibError vmError;
    metric_contex *ctx = (metric_contex *) calloc(1, sizeof(metric_contex));

    *contex = (metric_contex *) ctx;
    if (ctx == NULL
        ||(ctx->prev_record = (metric_record *) calloc(METRIC_NUMBER, sizeof(metric_record))) == NULL
        || (ctx->curr_record = (metric_record *) calloc(METRIC_NUMBER, sizeof(metric_record))) == NULL
        ) {
        log_message(LOG_ERR, errno, 0, "calloc failed");
        return -1;
    }

    strncpy(ctx->domain, domain, sizeof(ctx->domain) - 1);
    if (get_host_name(ctx->host, sizeof(ctx->host)) == NULL)
        return -1;

    log_message(LOG_INFO, 0, 0, "domain = %s, host = %s, sample period = %d seconds, sizeof(metric_record) = %d, sizeof(metric_contex) = %d\n",
        ctx->domain, ctx->host, METRIC_PERIOD, sizeof(metric_record), sizeof(metric_contex));

    /* init target */
    for(i = 0, n = 0; action[i].init != NULL; i++) {
        rc = action[i].init(& action[i].ctx);
        if (rc != 0) {
             log_message(LOG_ERR, 0, 0, "Target %s initialization failure", action[i].target_name);
        } else {
            log_message(LOG_INFO, 0, 0, "Target %s initialization success", action[i].target_name);
            action[i].status = 1;
            n++;
        }
    }

    if (n < 1) return -1;

    ctx->action = action;
    init_metric_record(ctx->prev_record, METRIC_NUMBER, ctx->domain, ctx->host);
    init_metric_record(ctx->curr_record, METRIC_NUMBER, ctx->domain, ctx->host);

    vmError = VMGuestLib_OpenHandle(&ctx->vmHandle);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_OpenHandle failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    return 0;
}

static void xchg_metric_record(metric_record **left_record, metric_record **right_record)
{
    metric_record *t = *left_record;

    *left_record = *right_record;
    *right_record = t;
}

static int reset_metric_record(metric_record *record, int number)
{
    int i;

    if (number != METRIC_NUMBER)
        return -1;

    for(i = 0; i < number; i++) {
        record[i].metric[0] = '\0';
        record[i].value = 0;
    }

    return 0;
}

int vmware_metric_fetch_and_save(metric_contex *ctx)
{
    int i, n, rc;
    VMGuestLibError vmError;
    VMSessionId tmpSessionId;

    vmError = VMGuestLib_UpdateInfo(ctx->vmHandle);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_UpdateInfo failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    vmError = VMGuestLib_GetSessionId(ctx->vmHandle, &tmpSessionId);
    if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
        log_message(LOG_ERR, 0, 0, "VMGuestLib_GetSessionId failed: %s", VMGuestLib_GetErrorText(vmError));
        return -1;
    }

    if (tmpSessionId == 0) {
        log_message(LOG_ERR, 0, 0, "Error: Got zero session Id from GuestLib");
        return -1;
    }

    if (tmpSessionId != ctx->vmSessionId) {
        if (ctx->vmSessionId == 0)
            log_message(LOG_WARNING, 0, 0, "SESSION INITIATED: session ID is 0x%"FMT64"x\n", tmpSessionId);
        else
            log_message(LOG_WARNING, 0, 0, "SESSION CHANGED: New session ID is 0x%"FMT64"x, Old session ID is 0x%"FMT64"x\n", tmpSessionId, ctx->vmSessionId);

        ctx->vmSessionId = tmpSessionId;
        reset_metric_record(ctx->prev_record, METRIC_NUMBER);
    }

    init_metric_record(ctx->curr_record, METRIC_NUMBER, ctx->domain, ctx->host);
    rc = read_metric_record(ctx->vmHandle, ctx->curr_record, METRIC_NUMBER);
    if (rc != 0 || strlen(ctx->prev_record[0].metric) < 1) {
        xchg_metric_record(&ctx->prev_record, &ctx->curr_record);
        return rc;
    }

    for(i = 0, n = 0; action[i].init != NULL; i++) {
        if (action[i].status != 0) {
            rc = action[i].save(action[i].ctx, ctx->prev_record, ctx->curr_record, METRIC_NUMBER);
            if (rc != 0)
                log_message(LOG_ERR, 0, 0, "Target %s write failure", action[i].target_name);
            else
                n += 1;
        } else {
            log_message(LOG_ERR, 0, 0, "Target %s not used", action[i].target_name);
        }
    }

    xchg_metric_record(&ctx->prev_record, &ctx->curr_record);

    return (n == 0) ? -1 : 0;
}

int vmware_metric_fini(metric_contex **ctx)
{
    if (ctx) {
        VMGuestLibError vmError= VMGuestLib_CloseHandle((*ctx)->vmHandle);
        if (vmError != VMGUESTLIB_ERROR_SUCCESS) {
            log_message(LOG_ERR, 0, 0, "VMGuestLib_CloseHandle failed: %s\n", VMGuestLib_GetErrorText(vmError));
            return -1;
        }

        free((*ctx)->prev_record);
        free((*ctx)->curr_record);

        free(*ctx);
        *ctx = NULL;
    }

    return 0;
}


void log_message(int level, int error, int lasterror, char *format, ...)
{
    int n, len;
    char buf[512];
    const char *errarg[] = { buf };
    const char *errsmall = "!!!-!!! log_message: buffer too small";
    va_list ap;
    WORD wType;
    DWORD dwEventId;
    SYSTEMTIME st;
    TIME_ZONE_INFORMATION tzi;

    GetTimeZoneInformation(&tzi);
    GetLocalTime(&st);

    len = _snprintf(buf, sizeof(buf), "[%04d-%02d-%02dT%02d:%02d:%02d.%03d%+03d00]",
        st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds, -tzi.Bias / 60);
    if (len < 0 || len >= sizeof(buf))
        goto buffer_small;

    if (error == 0 && lasterror == 0) {
        n = _snprintf(buf + len, sizeof(buf) - len, "%s", " - ");
        if (n < 0 || n >= (int) sizeof(buf) - len)
            goto buffer_small;
        len += n;
    } else {
        if (error != 0) {
            n = _snprintf(buf + len, sizeof(buf) - len, " - [errno = %d, message = %s] - ", error, strerror(error));
            if (n < 0 || n >= (int) sizeof(buf) - len)
                goto buffer_small;
            len += n;
        }

        if (lasterror != 0) {
            n = _snprintf(buf + len, sizeof(buf) - len, " - [last error = %d, message = ", lasterror);
            if (n < 0 || n >= (int) sizeof(buf) - len)
                goto buffer_small;
            len += n;
            n = FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, NULL, lasterror, 0, buf + len, sizeof(buf) - len, NULL);
            if (n < 1 || n >= (int) sizeof(buf) - len)
                goto buffer_small;
            while(1) {
                char c = buf[len + n - 1];
                if (c == '\n' || c == '\r')
                    n -= 1;
                else
                    break;
                if (n < 1) break;
            }
            len += n;
            n = _snprintf(buf + len, sizeof(buf) - len, "] - ");
            if (n < 1 || n >= (int) sizeof(buf) - len)
                goto buffer_small;
            len += n;
        }
    }

    va_start(ap, format);
    n = vsnprintf(buf + len, sizeof(buf) - len, format, ap);
    va_end(ap);

    if (n == 0)
        n = _snprintf(buf + len, sizeof(buf) - len, "%s", "[empty message]");

    if (n < 0 || n >= (int) sizeof(buf) - len)
        goto buffer_small;

    len += n;

report_event:
    if (level <= LOG_INFO)
        fprintf(stdout, "%s\n", errarg[0]);
    else
        fprintf(stderr, "%s\n", errarg[0]);

    if (_log_event_source == NULL)
        return;

    if (level <= LOG_INFO) {
        wType = EVENTLOG_INFORMATION_TYPE;
        dwEventId = MSG_ONE_FMT_INFO;
    } else if (level <= LOG_WARNING) {
        wType = EVENTLOG_WARNING_TYPE;
        dwEventId = MSG_ONE_FMT_WARN;
    } else {
        wType = EVENTLOG_ERROR_TYPE;
        dwEventId = MSG_ONE_FMT_ERR;
    }

    ReportEventA(_log_event_source, wType, 0, dwEventId, NULL, 1, 0, errarg, NULL);
    return;

buffer_small:
    do {
        n = strlen(errsmall) + 1;
        if (n >= sizeof(buf))
            errarg[0] = errsmall;
        else
            memcpy(buf + (sizeof(buf) - n), errsmall, n);

        goto report_event;
    } while(0);
}

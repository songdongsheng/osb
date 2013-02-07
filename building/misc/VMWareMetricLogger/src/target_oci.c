#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>

#include "oci.h"

#include "vm_metric.h"

#define OCI_DBQ     "//192.168.30.240:1521/dre"
#define OCI_UID     "dre_own"
#define OCI_PWD     "etc42"

typedef struct {
    OCIEnv *oracle_env;
    OCIError *oracle_err;
    OCISvcCtx *oracle_svc;
    OCIStmt *oracle_stmt;

    OCIBind *oracle_bind[METRIC_NUMBER];

    char id[METRIC_NUMBER][36 + 1];
    char domain[METRIC_NUMBER][63 + 1];
    char host[METRIC_NUMBER][63 + 1];
    char metric[METRIC_NUMBER][63 + 1];
    char isotime[METRIC_NUMBER][34 + 1]; /* SQLT_STR */
    double value[METRIC_NUMBER]; /* SQLT_BDOUBLE */
    int period[METRIC_NUMBER]; /* SQLT_INT */
    char unixtime[METRIC_NUMBER][21 + 1];

} oci_contex;

static void report_oci_error(OCIError *err, char *fun)
{
    char  msgbuf[256];
    sb4   errorcode = 0;

    OCIErrorGet(err, 1, NULL, &errorcode, (OraText *) msgbuf, sizeof(msgbuf), OCI_HTYPE_ERROR);
    fprintf(stderr, "%s failed (%d): %s\n", fun, errorcode, msgbuf);

    return;
}

static int bind_input(oci_contex *ctx)
{
    /* ID, DOMAIN, HOST, METRIC, VALUE, PERIOD, UNIXTIME, ISOTIME */
    if    (OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[0], ctx->oracle_err, (OraText *) "ID", strlen("ID"), ctx->id, sizeof(ctx->id[0]), SQLT_STR, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[1], ctx->oracle_err, (OraText *) "DOMAIN", strlen("DOMAIN"), ctx->domain, sizeof(ctx->domain[0]), SQLT_STR, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[2], ctx->oracle_err, (OraText *) "HOST", strlen("HOST"), ctx->host, sizeof(ctx->host[0]), SQLT_STR, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[3], ctx->oracle_err, (OraText *) "METRIC", strlen("METRIC"), ctx->metric, sizeof(ctx->metric[0]), SQLT_STR, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[4], ctx->oracle_err, (OraText *) "VALUE", strlen("VALUE"), ctx->value, sizeof(ctx->value[0]), SQLT_BDOUBLE, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[5], ctx->oracle_err, (OraText *) "PERIOD", strlen("PERIOD"), ctx->period, sizeof(ctx->period[0]), SQLT_INT, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[6], ctx->oracle_err, (OraText *) "UNIXTIME", strlen("UNIXTIME"), ctx->unixtime, sizeof(ctx->unixtime[0]), SQLT_STR, 0, 0, 0, 0, 0, OCI_DEFAULT)
        || OCIBindByName(ctx->oracle_stmt, & ctx->oracle_bind[7], ctx->oracle_err, (OraText *) "ISOTIME", strlen("ISOTIME"), ctx->isotime, sizeof(ctx->isotime[0]), SQLT_STR, 0, 0, 0, 0, 0, OCI_DEFAULT))
    {
        report_oci_error(ctx->oracle_err, "OCIBindByName");
        return OCI_ERROR;
    }

    fprintf(stdout, "OCIBindByName success\n");

    if    (OCIBindArrayOfStruct(ctx->oracle_bind[0], ctx->oracle_err, sizeof(ctx->id[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[1], ctx->oracle_err, sizeof(ctx->domain[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[2], ctx->oracle_err, sizeof(ctx->host[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[3], ctx->oracle_err, sizeof(ctx->metric[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[4], ctx->oracle_err, sizeof(ctx->value[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[5], ctx->oracle_err, sizeof(ctx->period[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[6], ctx->oracle_err, sizeof(ctx->unixtime[0]), 0, 0, 0)
        || OCIBindArrayOfStruct(ctx->oracle_bind[7], ctx->oracle_err, sizeof(ctx->isotime[0]), 0, 0, 0))
    {
        report_oci_error(ctx->oracle_err, "OCIBindArrayOfStruct");
        return OCI_ERROR;
    }

    fprintf(stdout, "OCIBindArrayOfStruct success\n");

  return OCI_SUCCESS;
}

int oci_target_init(struct target_contex **contex)
{
    int rc;
    oci_contex *ctx = (oci_contex *) calloc(1, sizeof(oci_contex));
    char *sql = "INSERT INTO METRIC_LOG(ID, DOMAIN, HOST, METRIC, VALUE, PERIOD, UNIXTIME, ISOTIME) VALUES(:ID, :DOMAIN, :HOST, :METRIC, :VALUE, :PERIOD, :UNIXTIME, :ISOTIME)";

    *contex = (struct target_contex *) ctx;
    if (ctx == NULL) {
        return -1;
    }

    /* NLS_CHARACTERSET               AL32UTF8      873 (OCINlsCharSetNameToId)  */
    /* NLS_NCHAR_CHARACTERSET         AL16UTF16     2000 (OCINlsCharSetNameToId) */
    /* NLS_LENGTH_SEMANTICS           BYTE */
    rc = OCIEnvNlsCreate(&ctx->oracle_env, OCI_THREADED | OCI_NEW_LENGTH_SEMANTICS, NULL, NULL, NULL, NULL, 0, NULL, 873, 873);
    if (rc != 0) {
        fprintf(stderr, "OCIEnvCreate failed\n");
        return -1;
    }

    /* create err, stmt */
    OCIHandleAlloc(ctx->oracle_env, (void **) &ctx->oracle_err, OCI_HTYPE_ERROR, 0, NULL);
    OCIHandleAlloc(ctx->oracle_env, (void **) &ctx->oracle_stmt, OCI_HTYPE_STMT, 0, NULL);

    /* logon */
    rc = OCILogon2(ctx->oracle_env, ctx->oracle_err, &ctx->oracle_svc, OCI_UID, strlen(OCI_UID), OCI_PWD, strlen(OCI_PWD), OCI_DBQ, strlen(OCI_DBQ), OCI_LOGON2_STMTCACHE);
    if (rc != OCI_SUCCESS) {
        report_oci_error(ctx->oracle_err, "OCILogon2");
        OCIHandleFree(ctx->oracle_env, OCI_HTYPE_ENV);
        return -1;
    }

    fprintf(stdout, "OCILogon2 success\n");

    /* prepare stmt */
    rc = OCIStmtPrepare(ctx->oracle_stmt, ctx->oracle_err, (OraText *) sql, strlen(sql), OCI_NTV_SYNTAX, OCI_DEFAULT);
    if (rc != OCI_SUCCESS) {
        report_oci_error(ctx->oracle_err, "OCIStmtPrepare");
        OCILogoff(ctx->oracle_svc, ctx->oracle_err);
        OCIHandleFree(ctx->oracle_env, OCI_HTYPE_ENV);
        return -1;
    }

    fprintf(stdout, "OCIStmtPrepare success\n");

    if (bind_input(ctx) != OCI_SUCCESS) {
        OCILogoff(ctx->oracle_svc, ctx->oracle_err);
        OCIHandleFree(ctx->oracle_env, OCI_HTYPE_ENV);
        return -1;
    }

    return 0;
}

int oci_target_save(struct target_contex *contex, metric_record *prev_record, metric_record *curr_record, int number)
{
    int i, rc;
    oci_contex *ctx = (oci_contex *) contex;
    if (number != METRIC_NUMBER)
        return -1;

    for(i = 0; i < number; i++) {
        double value;
        if (strcmp("ElapsedMs", curr_record[i].metric) == 0 ||
            strcmp("CpuUsedMs", curr_record[i].metric) == 0 ||
            strcmp("CpuStolenMs", curr_record[i].metric) == 0) {
                value = ctx->value[i] = curr_record[i].value - prev_record[i].value;
        } else {
            value = ctx->value[i] = curr_record[i].value;
        }

        ctx->period[i] = curr_record[i].period;

        strcpy(ctx->id[i], curr_record[i].id);
        strcpy(ctx->domain[i], curr_record[i].domain);
        strcpy(ctx->host[i], curr_record[i].host);
        strcpy(ctx->metric[i], curr_record[i].metric);
        strcpy(ctx->isotime[i], curr_record[i].isotime);
        sprintf(ctx->unixtime[i], "%I64d", curr_record[i].unixtime);

        fprintf(stdout, "metric_record: {\"id\" : \"%s\", \"domain\" : \"%s\", \"host\" : \"%s\", \"metric\" : \"%s\", \"value\" : %lf, \"period\" : %d, \"unixtime\" : %I64d, \"isotime\" : \"%s\"}\n",
            curr_record[i].id, curr_record[i].domain, curr_record[i].host, curr_record[i].metric, value, curr_record[i].period,
            curr_record[i].unixtime, curr_record[i].isotime);
    }

    rc = OCIStmtExecute(ctx->oracle_svc, ctx->oracle_stmt, ctx->oracle_err, number, 0, 0, 0, OCI_DEFAULT);
    if (rc != OCI_SUCCESS) {
        report_oci_error(ctx->oracle_err, "OCIStmtExecute");
        OCITransRollback(ctx->oracle_svc, ctx->oracle_err, 0);
        return -1;
    }

    fprintf(stdout, "OCIStmtExecute success\n");

    OCITransCommit(ctx->oracle_svc, ctx->oracle_err, 0);

    fprintf(stdout, "OCITransCommit success\n");

    return 0;
}

int oci_target_fini(struct target_contex **contex)
{
    if (contex) {
        oci_contex *ctx = (oci_contex *) *contex;

        OCILogoff(ctx->oracle_svc, ctx->oracle_err);
        OCIHandleFree(ctx->oracle_env, OCI_HTYPE_ENV);

        free(*contex);
        *contex = NULL;
    }

    return 0;
}

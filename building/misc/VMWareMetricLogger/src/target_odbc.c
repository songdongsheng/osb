#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>
#include <sqlext.h>

#include "vm_metric.h"

#define ODBC_CS_MSSQL   "Driver={Oracle in OraDb11g_home1};DBQ=//192.168.30.240:1521/dre;Uid=dre_own;Pwd=etc42"
#define ODBC_CS_ORACLE  "Driver={SQL Server Native Client 10.0};Server=192.168.30.201;Database=CRM25_CUSTOMER_LEBARA_DEV;Uid=sa;Pwd=sa"

typedef struct {
    HDBC hdbc;
} odbc_contex;

int odbc_target_init(struct target_contex **contex)
{
    odbc_contex *ctx = (odbc_contex *) malloc(sizeof(odbc_contex));
    *contex = (struct target_contex *) ctx;
    if (ctx == NULL) {
        return -1;
    }

    return 0;
}

int odbc_target_save(struct target_contex *ctx, metric_record *prev_record, metric_record *curr_record, int number)
{
    if (number != METRIC_NUMBER)
        return -1;

    /* TBD */

    return 0;
}

int odbc_target_fini(struct target_contex **ctx)
{
    if (ctx) {
        free(*ctx);
        *ctx = NULL;
    }

    return 0;
}

#ifndef VM_METRIC_INCLUDED
#define VM_METRIC_INCLUDED 1

#include <vmGuestLib.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LOG_DEBUG       1
#define LOG_INFO        2
#define LOG_NOTICE      3
#define LOG_WARNING     4
#define LOG_ERR         5

#define METRIC_NUMBER   7
#define METRIC_PERIOD   10
#define METRIC_MAX_SIZE 512

/*
  使用DataContractJsonSerializer序列化后的结果：
{"domain":"VM-GZ","host":"DRE-TEST-01","id":"a2f70343-efdb-4b49-bfb1-cb9927e6dda1","isotime":"2012-10-18T15:38:19.999+0800","metric":"CpuUsedMs","period":10,"unixtime":1350545900,"value":1808}

  $ echo '{"domain":"VM-GZ",...}' | python -mjson.tool
  {
      "domain": "VM-GZ",
      "host": "DRE-TEST-01",
      "id": "a2f70343-efdb-4b49-bfb1-cb9927e6dda1",
      "isotime": "2012-10-18T15:38:19.999+0800",
      "metric": "CpuUsedMs",
      "period": 10,
      "unixtime": 1350545900,
      "value": 1808
  }
 */
typedef struct {
    char id[36 + 1];
    char domain[63 + 1];
    char host[63 + 1];
    char metric[63 + 1];
    double value;
    int period;
    __int64 unixtime;
    char isotime[34 + 1];
} metric_record;

struct target_contex;

typedef int (* target_init)(struct target_contex **ctx);
typedef int (* target_save)(struct target_contex *ctx, metric_record *prev_record, metric_record *curr_record, int number);
typedef int (* target_fini)(struct target_contex **ctx);

typedef struct {
    char *target_name;
    target_init  init;
    target_save  save;
    target_fini  fini;
    struct target_contex *ctx;
    int status;
} target_action;

typedef struct {
    VMGuestLibHandle vmHandle;
    VMSessionId vmSessionId;
    char domain[64];
    char host[64];
    metric_record *prev_record;
    metric_record *curr_record;
    target_action *action;
} metric_contex;

int vmware_metric_init(metric_contex **ctx, char *domain);
int vmware_metric_fetch_and_save(metric_contex *ctx);
int vmware_metric_fini(metric_contex **ctx);

int udp_target_init(struct target_contex **contex);
int udp_target_save(struct target_contex *contex, metric_record *prev_record, metric_record *curr_record, int number);
int udp_target_fini(struct target_contex **ctx);

int oci_target_init(struct target_contex **contex);
int oci_target_save(struct target_contex *contex, metric_record *prev_record, metric_record *curr_record, int number);
int oci_target_fini(struct target_contex **ctx);

int odbc_target_init(struct target_contex **contex);
int odbc_target_save(struct target_contex *contex, metric_record *prev_record, metric_record *curr_record, int number);
int odbc_target_fini(struct target_contex **ctx);

extern HANDLE _log_event_source;
void log_message(int level, int error, int lasterror, char *format, ...);

unsigned int get_remain_time_as_ms(unsigned int seconds);
#ifdef __cplusplus
}
#endif

#endif /* not VM_METRIC_INCLUDED */

/*
 * sc stop "VMWare Metric Logger"
 * sc delete "VMWare Metric Logger"
 * sc create "VMWare Metric Logger" start= "delayed-auto" binPath= "C:\Windows\System32\VMWareMetricLogger.exe -d \"GZ-TEST\""
 * sc description "VMWare Metric Logger" "VMWare Metric Logger"
 */
#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>

#include "vm_metric.h"
#include "message.h"

#define METRIC_DOMAIN   "ES-LIVE-DRE-2.7"
#define SVC_NAME        "VMWare Metric Logger"

static struct {
    SERVICE_STATUS          status;
    SERVICE_STATUS_HANDLE   status_handle;
    HANDLE                  stop_event;
    HANDLE                  event_source;
    char                    domain[64];
} service_contex;

HANDLE _log_event_source = NULL;

void setup_event_source();

VOID WINAPI SvcCtrlHandler(DWORD);
VOID WINAPI SvcMain(DWORD, LPSTR *);
VOID WINAPI ReportSvcStatus(DWORD, DWORD, DWORD);

static void get_domain_name(char *domain, int size, int argc, char *argv[])
{
    int n = 1;

    if (domain[0] == '\0')
        strncpy(domain, METRIC_DOMAIN, size);

    while (n < argc) {
        if (strcmp(argv[n], "-d") == 0) {
            if ((n + 1) < argc) {
                strncpy(domain, argv[n + 1], size);
                n++;
            } else {
                log_message(LOG_WARNING, 0, 0, "option argv[%d]=%s requires argument", n, argv[n]);
            }
        } else {
            log_message(LOG_WARNING, 0, 0, "unknown parameter argv[%d]=%s", n, argv[n]);
        }

        n++;
    }

    domain[size - 1] = '\0';
}

int main(int argc, char *argv[])
{
    int rc;
    WSADATA wsa;
    SERVICE_TABLE_ENTRYA DispatchTable[] =
    {
        { SVC_NAME, SvcMain },
        { NULL, NULL }
    };

    memset(&service_contex, 0, sizeof(service_contex));
    service_contex.event_source = _log_event_source = RegisterEventSourceA(NULL, SVC_NAME);

    setup_event_source();

    rc = WSAStartup(MAKEWORD(2, 2), &wsa);
    if (rc != 0) {
        log_message(LOG_ERR, 0, rc, "WSAStartup failed");
        return -1;
    }

    get_domain_name(service_contex.domain, sizeof(service_contex.domain), argc, argv);

    /*
    This call returns when the service has stopped.
    The process should simply terminate when the call returns.
    */
    if (!StartServiceCtrlDispatcherA(DispatchTable))
    {
        log_message(LOG_ERR, 0, GetLastError(), "StartServiceCtrlDispatcherA failed");
    }

    WSACleanup();

    DeregisterEventSource(service_contex.event_source);

    return 0;
}

static void setup_event_source()
{
    HKEY key;
    char msgfile[MAX_PATH];
    DWORD dwData = EVENTLOG_ERROR_TYPE | EVENTLOG_WARNING_TYPE | EVENTLOG_INFORMATION_TYPE;

    if (ERROR_SUCCESS != RegCreateKeyExA(HKEY_LOCAL_MACHINE,
        "SYSTEM\\CurrentControlSet\\Services\\"
        "EventLog\\Application\\"SVC_NAME,
        0, NULL, REG_OPTION_NON_VOLATILE,
        KEY_SET_VALUE, NULL, &key, NULL))
    {
        log_message(LOG_ERR, 0, GetLastError(), "RegCreateKeyExA failed");
        return;
    }

    GetModuleFileNameA(NULL, msgfile, MAX_PATH);

    RegSetValueExA(key, "EventMessageFile", 0, REG_EXPAND_SZ, (BYTE *)msgfile, strlen(msgfile) + 1);
    RegSetValueExA(key, "TypesSupported",   0, REG_DWORD,    (BYTE *)&dwData, sizeof(dwData));

    RegCloseKey(key);
}

VOID WINAPI SvcCtrlHandler(DWORD dwCtrl)
{
    switch(dwCtrl)
    {
    case SERVICE_CONTROL_STOP:
        ReportSvcStatus(SERVICE_STOP_PENDING, NO_ERROR, 0);
        SetEvent(service_contex.stop_event);
        ReportSvcStatus(service_contex.status.dwCurrentState, NO_ERROR, 0);
        break;

    default:
        break;
    }
}

VOID WINAPI ReportSvcStatus(DWORD dwCurrentState,
    DWORD dwWin32ExitCode,
    DWORD dwWaitHint)
{
    static DWORD dwCheckPoint = 1;

    service_contex.status.dwCurrentState = dwCurrentState;
    service_contex.status.dwWin32ExitCode = dwWin32ExitCode;
    service_contex.status.dwWaitHint = dwWaitHint;

    if (dwCurrentState == SERVICE_START_PENDING)
        service_contex.status.dwControlsAccepted = 0;
    else
        service_contex.status.dwControlsAccepted = SERVICE_ACCEPT_STOP;

    if ((dwCurrentState == SERVICE_RUNNING) ||
        (dwCurrentState == SERVICE_STOPPED))
        service_contex.status.dwCheckPoint = 0;
    else
        service_contex.status.dwCheckPoint = dwCheckPoint++;

    // Report the status of the service to the SCM.
    SetServiceStatus(service_contex.status_handle, &service_contex.status);
}

VOID WINAPI SvcMain(DWORD dwArgc, LPSTR *lpszArgv)
{
    metric_contex *ctx;
    DWORD rc = WAIT_OBJECT_0;
    service_contex.status_handle = RegisterServiceCtrlHandlerA(SVC_NAME, SvcCtrlHandler);
    if (service_contex.status_handle == NULL)
        log_message(LOG_ERR, 0, GetLastError(), "RegisterServiceCtrlHandlerA failed");

    service_contex.status.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    service_contex.status.dwServiceSpecificExitCode = 0;

    ReportSvcStatus(SERVICE_START_PENDING, NO_ERROR, 1000);

    service_contex.stop_event = CreateEvent(
        NULL,    // default security attributes
        TRUE,    // manual reset event
        FALSE,   // not signaled
        NULL);   // no name
    if (service_contex.stop_event == NULL)
    {
        log_message(LOG_ERR, 0, GetLastError(), "CreateEvent failed");
        ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0);
        return;
    }

    ReportSvcStatus(SERVICE_RUNNING, NO_ERROR, 0);
    log_message(LOG_INFO, 0, 0, "%s", SVC_NAME" stared");

    get_domain_name(service_contex.domain, sizeof(service_contex.domain), dwArgc, lpszArgv);

    if (vmware_metric_init(&ctx, service_contex.domain)) {
        ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0);
        log_message(LOG_INFO, 0, 0, "%s", SVC_NAME" stopped");
        return;
    }

    while(1)
    {
        unsigned int t = get_remain_time_as_ms(METRIC_PERIOD);
        /* log_message(LOG_DEBUG, 0, 0, "WaitForSingleObjectEx with %d ms", t); */
        rc = WaitForSingleObjectEx(service_contex.stop_event, t, TRUE);
        if (rc == WAIT_TIMEOUT) {
            vmware_metric_fetch_and_save(ctx);
        } else {
            break;
        }
    }

    if (rc != WAIT_OBJECT_0)
        log_message(LOG_INFO, 0, GetLastError(), "WaitForSingleObjectEx failed");

    vmware_metric_fini(&ctx);

    ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0);
    log_message(LOG_INFO, 0, 0, "%s", SVC_NAME" stopped");
    return;
}

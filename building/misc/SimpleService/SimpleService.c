/*
 * sc create "Simple Service" start= "delayed-auto" binPath= "D:\var\vcs\hg\draft\bwb\SimpleService\Debug\SimpleService.exe"
 */
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <winsock2.h>
#include <tchar.h>

#pragma comment(lib, "advapi32.lib")

#include "message.h"

#define LOG_DEBUG       1
#define LOG_INFO        2
#define LOG_NOTICE      3
#define LOG_WARNING     4
#define LOG_ERR         5

#define SVC_NAME        "Simple Service"

static SERVICE_STATUS           gSvcStatus;
static SERVICE_STATUS_HANDLE    gSvcStatusHandle;
static HANDLE                   ghSvcStopEvent = NULL;
static HANDLE                   hEventSource = NULL;

VOID WINAPI SvcCtrlHandler(DWORD);
VOID WINAPI SvcMain(DWORD, LPSTR *);
VOID WINAPI ReportSvcStatus(DWORD, DWORD, DWORD);

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

    if (hEventSource == NULL)
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

    ReportEventA(hEventSource, wType, 0, dwEventId, NULL, 1, 0, errarg, NULL);
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

VOID WINAPI SvcMain(DWORD dwArgc, LPSTR *lpszArgv)
{
    gSvcStatusHandle = RegisterServiceCtrlHandlerA(SVC_NAME, SvcCtrlHandler);
    if (gSvcStatusHandle == NULL)
        log_message(LOG_INFO, 0, GetLastError(), "RegisterServiceCtrlHandlerA failed");

    gSvcStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    gSvcStatus.dwServiceSpecificExitCode = 0;

    ReportSvcStatus(SERVICE_START_PENDING, NO_ERROR, 1000);

    ghSvcStopEvent = CreateEvent(
        NULL,    // default security attributes
        TRUE,    // manual reset event
        FALSE,   // not signaled
        NULL);   // no name
    if (ghSvcStopEvent == NULL)
    {
        log_message(LOG_INFO, 0, GetLastError(), "CreateEvent failed");
        ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0);
        return;
    }

    ReportSvcStatus(SERVICE_RUNNING, NO_ERROR, 0);
    log_message(LOG_INFO, 0, 0, "%s", SVC_NAME" stared");

    while(1)
    {
        WaitForSingleObject(ghSvcStopEvent, INFINITE);
        ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0);
        log_message(LOG_INFO, 0, 0, "%s", SVC_NAME" stopped");
        return;
    }
}

VOID WINAPI SvcCtrlHandler(DWORD dwCtrl)
{
    switch(dwCtrl)
    {
    case SERVICE_CONTROL_STOP:
        ReportSvcStatus(SERVICE_STOP_PENDING, NO_ERROR, 0);
        SetEvent(ghSvcStopEvent);
        ReportSvcStatus(gSvcStatus.dwCurrentState, NO_ERROR, 0);
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

    gSvcStatus.dwCurrentState = dwCurrentState;
    gSvcStatus.dwWin32ExitCode = dwWin32ExitCode;
    gSvcStatus.dwWaitHint = dwWaitHint;

    if (dwCurrentState == SERVICE_START_PENDING)
        gSvcStatus.dwControlsAccepted = 0;
    else
        gSvcStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP;

    if ((dwCurrentState == SERVICE_RUNNING) ||
        (dwCurrentState == SERVICE_STOPPED))
        gSvcStatus.dwCheckPoint = 0;
    else
        gSvcStatus.dwCheckPoint = dwCheckPoint++;

    // Report the status of the service to the SCM.
    SetServiceStatus(gSvcStatusHandle, &gSvcStatus);
}

int main(int argc, char *argv[])
{
    SERVICE_TABLE_ENTRYA DispatchTable[] =
    {
        { SVC_NAME, SvcMain },
        { NULL, NULL }
    };

    hEventSource = RegisterEventSourceA(NULL, SVC_NAME);

    setup_event_source();

    /*
    This call returns when the service has stopped.
    The process should simply terminate when the call returns.
    */
    if (!StartServiceCtrlDispatcherA(DispatchTable))
    {
        log_message(LOG_ERR, 0, GetLastError(), "StartServiceCtrlDispatcherA failed");
    }

    DeregisterEventSource(hEventSource);

    return 0;
}

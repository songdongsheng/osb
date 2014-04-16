/*
 * CFLAGS="${CFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"
 * https://git.gnome.org/browse/gtk+/commit/?id=8af16c5d4481a517cc7c400b97d469ee550ffd79
 * LD 的 --retain-symbols-file 控制静态库符号表，--version-script 对应共享库符号表
 */

#if defined _WIN32 || defined __CYGWIN__
  #define API_LOCAL

  #ifdef BUILDING_DLL
    #ifdef __GNUC__
      #define API_PUBLIC __attribute__ ((dllexport))
    #else
      #define API_PUBLIC __declspec(dllexport) /* Note: actually gcc seems to also supports this syntax. */
    #endif
  #else
    #ifdef __GNUC__
      #define API_PUBLIC __attribute__ ((dllimport))
    #else
      #define API_PUBLIC __declspec(dllimport) /* Note: actually gcc seems to also supports this syntax. */
    #endif
  #endif
#else
  #if __GNUC__ >= 4
    #define API_LOCAL  __attribute__ ((visibility ("hidden")))
    #define API_PUBLIC __attribute__ ((visibility ("default")))
  #else
    #define API_LOCAL
    #define API_PUBLIC
  #endif
#endif

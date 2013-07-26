/*
 * CFLAGS="${CFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"
 * https://git.gnome.org/browse/gtk+/commit/?id=8af16c5d4481a517cc7c400b97d469ee550ffd79
 * LD 的 --retain-symbols-file 控制静态库符号表，--version-script 对应共享库符号表
 */

#if defined(_WIN32) || defined(__CYGWIN__)
  #if defined(XXX_DECLARE_STATIC)
    #define XXX_PUBLIC
  #elif defined(XXX_DECLARE_EXPORT)
    #define XXX_PUBLIC __declspec(dllexport)
  #else
    #define XXX_PUBLIC __declspec(dllimport)
  #endif

  #define XXX_LOCAL
#else
  #if __GNUC__ >= 4
    #define XXX_PUBLIC __attribute__ ((visibility ("default")))
    #define XXX_LOCAL  __attribute__ ((visibility ("hidden")))
  #else
    #define XXX_PUBLIC
    #define XXX_LOCAL
  #endif
#endif

#ifndef _CONFIG_H
#define _CONFIG_H 1

#include <stdint.h>

#define ENABLE_RELOCATABLE      1

#define HAVE_ICONV              1
#define ICONV_CONST
#define DEPENDS_ON_LIBICONV     1

#define HAVE_SNPRINTF           1
#define HAVE_DECL__SNPRINTF     1
#define HAVE_FWPRINTF           1
#define HAVE_DECL__SNWPRINTF    1
#define HAVE_ASPRINTF           1

#define USE_WINDOWS_THREADS     1
#define LIBDIR                  ""
#define LOCALE_ALIAS_PATH       ""
#define LOCALEDIR               ""
    
#define NO_XMALLOC      1
#define HAVE_ALLOCA     1
#define HAVE_GETCWD     1

#define _GL_INLINE     __inline
#define _GL_INLINE_HEADER_BEGIN
#define _GL_INLINE_HEADER_END

#define __libc_lock_t                   gl_lock_t
#define __libc_lock_define              gl_lock_define
#define __libc_lock_define_initialized  gl_lock_define_initialized
#define __libc_lock_init                gl_lock_init
#define __libc_lock_lock                gl_lock_lock
#define __libc_lock_unlock              gl_lock_unlock
#define __libc_lock_recursive_t                   gl_recursive_lock_t
#define __libc_lock_define_recursive              gl_recursive_lock_define
#define __libc_lock_define_initialized_recursive  gl_recursive_lock_define_initialized
#define __libc_lock_init_recursive                gl_recursive_lock_init
#define __libc_lock_lock_recursive                gl_recursive_lock_lock
#define __libc_lock_unlock_recursive              gl_recursive_lock_unlock

#endif /* config.h */

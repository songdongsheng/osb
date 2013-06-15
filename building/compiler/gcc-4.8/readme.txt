gcc-4_8-branch/libgcc/config.host
    i[34567]86-*-mingw*)
        if test x$enable_sjlj_exceptions = xyes; then
                tmake_eh_file="i386/t-sjlj-eh"
        else
                tmake_eh_file="i386/t-dw2-eh"
                md_unwind_header=i386/w32-unwind.h
        fi

    x86_64-*-mingw*)
        if test x$enable_sjlj_exceptions = xyes; then
                tmake_eh_file="i386/t-sjlj-eh"
        else
                tmake_eh_file="i386/t-seh-eh"
        fi

/i386\/t-seh-eh/

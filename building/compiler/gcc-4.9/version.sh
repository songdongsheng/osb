#!/bin/sh

export SYS_ROOT=${HOME}/native/gcc-4.9-win32
export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/trunk
export MINGW_W64_SRC_ROOT=${HOME}/vcs/svn/mingw-w64/trunk

cat << EOF > $SYS_ROOT/version.txt
WARNING:
    Due to PR57848 (http://gcc.gnu.org/bugzilla/show_bug.cgi?id=57848),    
    your host computer must support SSE 4.2 instructions, and this gcc package build with
    '--with-arch=corei7' (http://gcc.gnu.org/onlinedocs/gcc/i386-and-x86_002d64-Options.html).

*) binutils 2.23.2
http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.gz

*) gdb 7.6
http://ftp.gnu.org/gnu/gdb/gdb-7.6.tar.bz2

*) make 3.8.2
http://ftp.gnu.org/gnu/make/make-3.82.tar.gz

*) gmp 5.1.2
ftp://ftp.gmplib.org/pub/gmp-5.1.2/gmp-5.1.2.tar.xz
http://ftp.gnu.org/gnu/gmp/gmp-5.1.2.tar.xz

*) mpfr 3.1.2
http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.xz

*) mpc 1.0.1
http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz

*) cloog (CLOOG_VERSION_MAJOR == 0 && CLOOG_VERSION_MINOR == 18 && CLOOG_VERSION_REVISION >= 0)
http://www.bastoul.net/cloog/pages/download/cloog-0.18.0.tar.gz

*) isl (strncmp (isl_version (), "isl-0.11", strlen ("isl-0.11")) == 0)
ftp://ftp.linux.student.kuleuven.be/pub/people/skimo/isl/isl-0.11.2.tar.bz2

*) mingw-w64
EOF

svn info $MINGW_W64_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $MINGW_W64_SRC_ROOT >> $SYS_ROOT/version.txt
echo >> $SYS_ROOT/version.txt

echo "*) gcc" >> $SYS_ROOT/version.txt
svn info $GCC_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $GCC_SRC_ROOT >> $SYS_ROOT/version.txt

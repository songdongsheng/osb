#!/bin/sh

export SYS_ROOT=$1
export GCC_SRC_ROOT=$2
export MINGW_W64_SRC_ROOT=$3

cat << EOF > $SYS_ROOT/version.txt
WARNING:
    For 64-bit gcc, your host computer must have SSSE3 instruction set support.

*) binutils 2.23.2
http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.gz

*) gdb 7.6
http://ftp.gnu.org/gnu/gdb/gdb-7.6.tar.bz2

*) make 3.8.2
http://ftp.gnu.org/gnu/make/make-3.82.tar.gz

*) gmp 5.0.5
ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.xz
http://ftp.gnu.org/gnu/gmp/gmp-5.0.5.tar.xz

*) mpfr 2.4.2
http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.xz
http://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.xz

*) mpc 1.0.1
http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz

*) mingw-w64
EOF

svn info $MINGW_W64_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $MINGW_W64_SRC_ROOT >> $SYS_ROOT/version.txt
echo >> $SYS_ROOT/version.txt

echo "*) gcc" >> $SYS_ROOT/version.txt
svn info $GCC_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $GCC_SRC_ROOT >> $SYS_ROOT/version.txt

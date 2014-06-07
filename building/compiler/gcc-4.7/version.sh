#!/bin/sh

export SYS_ROOT=$1
export GCC_SRC_ROOT=$2
export MINGW_W64_SRC_ROOT=$3

cat << EOF > $SYS_ROOT/version.txt
*) binutils 2.24
http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz

*) gdb 7.7.1
http://ftp.gnu.org/gnu/gdb/gdb-7.7.1.tar.bz2

*) make 4.0
http://ftp.gnu.org/gnu/make/make-4.0.tar.bz2

*) gmp 5.0.5
ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.xz
http://ftp.gnu.org/gnu/gmp/gmp-5.0.5.tar.xz

*) mpfr 2.4.2-p3
http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.xz
http://www.mpfr.org/mpfr-2.4.2/allpatches
http://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.xz

*) mpc 1.0.2
http://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz

*) mingw-w64
EOF

GIT_DIR=$MINGW_W64_SRC_ROOT/.git git log -1 >> $SYS_ROOT/version.txt
echo >> $SYS_ROOT/version.txt

echo "*) gcc" >> $SYS_ROOT/version.txt
svn info $GCC_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $GCC_SRC_ROOT >> $SYS_ROOT/version.txt

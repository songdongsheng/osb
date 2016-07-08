#!/bin/sh

export SYS_ROOT=$1
export GCC_SRC_ROOT=$2
export MINGW_W64_SRC_ROOT=$3

cat << EOF > $SYS_ROOT/version.txt
*) binutils 2.26.1
https://ftp.gnu.org/gnu/binutils/binutils-2.26.1.tar.gz

*) gdb 7.11.1
https://ftp.gnu.org/gnu/gdb/gdb-7.11.1.tar.xz

*) make 4.2.1
https://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2

*) gmp 6.1.1
https://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz

*) mpfr 3.1.4 p3
http://www.mpfr.org/mpfr-3.1.4/mpfr-3.1.4.tar.xz
http://www.mpfr.org/mpfr-3.1.4/allpatches
wget -q -O - http://www.mpfr.org/mpfr-3.1.4/allpatches | patch -p1

*) mpc 1.0.3
https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz

*) isl 0.15 [ISL_CHECK_VERSION(0,15)]
http://isl.gforge.inria.fr/isl-0.15.tar.xz

*) cloog 0.18.4 [CLOOG_CHECK_VERSION(0,18,0)]
http://www.bastoul.net/cloog/pages/download/cloog-0.18.4.tar.gz

*) mingw-w64 master
EOF

GIT_DIR=$MINGW_W64_SRC_ROOT/.git git log -1 origin >> $SYS_ROOT/version.txt
echo >> $SYS_ROOT/version.txt

echo "*) gcc" >> $SYS_ROOT/version.txt
svn info $GCC_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $GCC_SRC_ROOT >> $SYS_ROOT/version.txt

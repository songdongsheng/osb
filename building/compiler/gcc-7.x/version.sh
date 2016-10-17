#!/bin/sh

export SYS_ROOT=$1
export GCC_SRC_ROOT=$2
export MINGW_W64_SRC_ROOT=$3

cat << EOF > $SYS_ROOT/version.txt
*) binutils 2.27
https://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.bz2

*) gdb 7.12
https://ftp.gnu.org/gnu/gdb/gdb-7.12.tar.xz

*) make 4.2.1
https://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2

*) gmp 6.1.1
https://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz

*) mpfr 3.1.5
http://www.mpfr.org/mpfr-3.1.5/mpfr-3.1.5.tar.xz
http://www.mpfr.org/mpfr-3.1.5/allpatches
wget -q -O - http://www.mpfr.org/mpfr-3.1.5/allpatches | patch -p1

*) mpc 1.0.3
https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz

*) isl 0.17.1
http://isl.gforge.inria.fr/isl-0.17.1.tar.xz

*) mingw-w64 master
EOF

GIT_DIR=$MINGW_W64_SRC_ROOT/.git git log -1 origin >> $SYS_ROOT/version.txt
echo >> $SYS_ROOT/version.txt

echo "*) gcc" >> $SYS_ROOT/version.txt
svn info $GCC_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $GCC_SRC_ROOT >> $SYS_ROOT/version.txt

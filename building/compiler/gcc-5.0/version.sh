#!/bin/sh

export SYS_ROOT=$1
export GCC_SRC_ROOT=$2
export MINGW_W64_SRC_ROOT=$3

cat << EOF > $SYS_ROOT/version.txt
*) binutils 2.25
http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz

*) gdb 7.8.1
http://ftp.gnu.org/gnu/gdb/gdb-7.8.1.tar.xz

*) make 4.1
http://ftp.gnu.org/gnu/make/make-4.1.tar.bz2

*) gmp 5.1.3
http://ftp.gnu.org/gnu/gmp/gmp-5.1.3.tar.xz

*) mpfr 3.1.2-p11
http://www.mpfr.org/mpfr-3.1.2/mpfr-3.1.2.tar.xz
http://www.mpfr.org/mpfr-3.1.2/allpatches
wget -q -O - http://www.mpfr.org/mpfr-3.1.2/allpatches | patch -p1

*) mpc 1.0.2
http://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz

*) isl (strncmp (isl_version (), "isl-0.12", strlen ("isl-0.12")) != 0)
http://isl.gforge.inria.fr/isl-0.12.2.tar.bz2

*) mingw-w64 master
EOF

GIT_DIR=$MINGW_W64_SRC_ROOT/.git git log -1 origin >> $SYS_ROOT/version.txt
echo >> $SYS_ROOT/version.txt

echo "*) gcc" >> $SYS_ROOT/version.txt
svn info $GCC_SRC_ROOT >> $SYS_ROOT/version.txt
svn log -r COMMITTED $GCC_SRC_ROOT >> $SYS_ROOT/version.txt

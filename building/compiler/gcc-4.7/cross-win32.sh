#!/bin/sh
#
# <prefix>-dlltool moldname-msvcrt.def -U --dllname msvcr100.dll
# lib32_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
# lib64_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
#
# sudo apt-get install texinfo libexpat1-dev zlib1g-dev
#
# i686-w64-mingw32-gcc     -dM -E -  < /dev/null
# i686-w64-mingw32-gcc     -x c -shared -s -o t-w32.dll - < /dev/null
# i686-w64-mingw32-objdump -x t-w32.dll | grep -A 25 "The Export Tables"
#
# path/to/src/configure --build=`/usr/share/misc/config.guess` --host=i686-w64-mingw32 --prefix=/tmp/i686-w64-mingw32 --disable-nls
#

export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-4_7-branch
export MINGW_W64_SRC_ROOT=${HOME}/vcs/svn/mingw-w64/stable/v2.x
export BINUTILS_SRC_ROOT=${HOME}/src/binutils-2.23.2

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=i686-w64-mingw32
export LOGGER_TAG=cross-win32-gcc47
export SYS_ROOT=${HOME}/cross/i686-windows-gcc47
export OBJ_ROOT=${HOME}/obj/${TARGET_TRIPLET}-gcc47
export PATH=${SYS_ROOT}/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${OBJ_ROOT}

mkdir -p ${SYS_ROOT}/include ${SYS_ROOT}/lib ${SYS_ROOT}/${TARGET_TRIPLET}
cd ${SYS_ROOT} ; ln -s ${TARGET_TRIPLET} mingw

################ binutils ################
rm -fr ${OBJ_ROOT}/binutils
mkdir -p ${OBJ_ROOT}/binutils
cd  ${OBJ_ROOT}/binutils

${BINUTILS_SRC_ROOT}/configure --prefix=${SYS_ROOT} --with-sysroot=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
    --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32 --disable-nls

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build binutils failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build binutils success"

# ################ mingw-w64-headers ################
rm -fr ${OBJ_ROOT}/mingw-w64-header
mkdir -p ${OBJ_ROOT}/mingw-w64-header
cd  ${OBJ_ROOT}/mingw-w64-header

${MINGW_W64_SRC_ROOT}/mingw-w64-headers/configure --prefix=${SYS_ROOT} \
    --host=${TARGET_TRIPLET} --enable-sdk=all

make install
logger -t ${LOGGER_TAG} -s "Build mingw-w64 (header) success"

################ gcc - core ################
rm -fr ${OBJ_ROOT}/gcc
mkdir -p ${OBJ_ROOT}/gcc
cd  ${OBJ_ROOT}/gcc

${GCC_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT} \
    --with-sysroot=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
    --enable-targets=all --disable-nls \
    --enable-checking=release --enable-languages=c,c++,fortran \
    --with-arch-64=core2 --with-arch-32=i686 --with-tune=generic

make -j${NR_JOBS} all-gcc; make install-gcc
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (core) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (core) success"

# ################ mingw-w64 CRT ################
rm -fr ${OBJ_ROOT}/mingw-w64-crt
mkdir -p ${OBJ_ROOT}/mingw-w64-crt
cd  ${OBJ_ROOT}/mingw-w64-crt

${MINGW_W64_SRC_ROOT}/mingw-w64-crt/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --enable-lib32 --enable-lib64 \
    --enable-wildcard

make -j${NR_JOBS}; make install
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build mingw-w64 (CRT) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build mingw-w64 (CRT) success"

# ################ mingw-w64 pthread support ################
# goto gcc
# make ${MAKE_FLAGS} all-target-libgcc
# make install-target-libgcc
# goto thread support

# ################ gcc - finally ################
cd  ${OBJ_ROOT}/gcc

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (finally) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (finally) success"

logger -t ${LOGGER_TAG} -s "Build finished"

#!/bin/sh
#
# <prefix>-dlltool moldname-msvcrt.def -U --dllname msvcr90.dll
# lib32_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
# lib64_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
#

export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-4_8-branch
export MINGW_W64_SRC_ROOT=${HOME}/vcs/svn/mingw-w64/trunk
export BINUTILS_SRC_ROOT=${HOME}/vcs/git/binutils
export GDB_SRC_ROOT=${HOME}/vcs/git/gdb

export MAKE_SRC_ROOT=${HOME}/src/make-3.82
export GMP_SRC_ROOT=${HOME}/src/gmp-5.1.1
export MPFR_SRC_ROOT=${HOME}/src/mpfr-3.1.2
export MPC_SRC_ROOT=${HOME}/src/mpc-1.0.1
export CLOOG_SRC_ROOT=${HOME}/src/cloog-0.18.0

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=x86_64-w64-mingw32
export LOGGER_TAG=cross-win64
export SYS_ROOT=${HOME}/cross/x86_64-windows
export PATH=${SYS_ROOT}/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${HOME}/obj/${TARGET_TRIPLET}

mkdir -p ${SYS_ROOT}/include ${SYS_ROOT}/lib ${SYS_ROOT}/${TARGET_TRIPLET}
cd ${SYS_ROOT} ; ln -s ${TARGET_TRIPLET} mingw
cd ${SYS_ROOT}/${TARGET_TRIPLET} ; ln -s ../include; ln -s ../lib

################ binutils ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/binutils
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/binutils
cd  ${HOME}/obj/${TARGET_TRIPLET}/binutils

${BINUTILS_SRC_ROOT}/configure --prefix=${SYS_ROOT} --with-sysroot=${SYS_ROOT} \
    --target=${TARGET_TRIPLET} --enable-targets=all

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build binutils failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build binutils success"

# ################ mingw-w64-headers ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/mingw-w64-header
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/mingw-w64-header
cd  ${HOME}/obj/${TARGET_TRIPLET}/mingw-w64-header

${MINGW_W64_SRC_ROOT}/mingw-w64-headers/configure --prefix=${SYS_ROOT} \
    --host=${TARGET_TRIPLET} --enable-sdk=all

make install
logger -t ${LOGGER_TAG} -s "Build mingw-w64 (header) success"

################ gcc - core ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/gcc
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/gcc
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc

${GCC_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT} \
    --with-sysroot=${SYS_ROOT} \
    --target=${TARGET_TRIPLET} \
    --enable-targets=all \
    --enable-checking=release --enable-languages=c,c++,fortran \
    --with-arch=x86-64 --with-tune=generic --with-fpmath=sse

make -j${NR_JOBS} all-gcc; make install-gcc
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (core) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (core) success"

# ################ mingw-w64 CRT ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/mingw-w64-crt
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/mingw-w64-crt
cd  ${HOME}/obj/${TARGET_TRIPLET}/mingw-w64-crt

${MINGW_W64_SRC_ROOT}/mingw-w64-crt/configure --prefix=${SYS_ROOT} \
    --host=${TARGET_TRIPLET} --enable-lib32 --enable-lib64 \
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
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (finally) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (finally) success"

logger -t ${LOGGER_TAG} -s "Build finished"

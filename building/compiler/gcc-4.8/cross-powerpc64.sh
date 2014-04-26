#!/bin/sh
#
# powerpc64-linux-gcc -dM -E -  < /dev/null
# powerpc64-linux-gcc -Werror -fstack-protector -xc /dev/null -S -o /dev/null
# path/to/src/configure --build=`/usr/share/misc/config.guess` --host=powerpc64-linux --prefix=/tmp/powerpc64-linux --disable-nls
#

export KERNEL_SRC_ROOT=${HOME}/vcs/git/linux
export EGLIBC_SRC_ROOT=${HOME}/vcs/svn/eglibc-2.18
export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-4_8-branch
export BINUTILS_SRC_ROOT=${HOME}/vcs/git/binutils

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=powerpc64-linux
export LOGGER_TAG=cross-powerpc64
export SYS_ROOT=${HOME}/cross/${TARGET_TRIPLET}
export PATH=${SYS_ROOT}/usr/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${HOME}/obj/${TARGET_TRIPLET}

################ Linux Kernel header files ################
cd ${KERNEL_SRC_ROOT}

make V=2 ARCH=powerpc pseries_defconfig
make V=2 ARCH=powerpc headers_check
make V=2 ARCH=powerpc INSTALL_HDR_PATH=${SYS_ROOT}/usr headers_install

logger -t ${LOGGER_TAG} -s "Build linux-libc-dev success"

################ binutils ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/binutils
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/binutils
cd  ${HOME}/obj/${TARGET_TRIPLET}/binutils

${BINUTILS_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT}/usr \
    --with-sysroot=${SYS_ROOT} \
    --target=${TARGET_TRIPLET}

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build binutils failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build binutils success"

################ gcc - core ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/gcc
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/gcc
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc

${GCC_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT}/usr \
    --with-sysroot=${SYS_ROOT} \
    --target=${TARGET_TRIPLET} \
    --with-cpu=power6 -with-tune=power8 \
    --enable-checking=release \
    --enable-languages=c,c++,fortran \
    --enable-fully-dynamic-string \
    --disable-multilib --disable-libssp

make -j${NR_JOBS} all-gcc ;
make install-strip-gcc
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (core) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (core) success"

################ eglibc - headers ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/eglibc
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/eglibc
cd  ${HOME}/obj/${TARGET_TRIPLET}/eglibc

install -m 0755 -d ${SYS_ROOT}/usr/include
install -m 0644 -t ${SYS_ROOT}/usr/include ${EGLIBC_SRC_ROOT}/libc/sysdeps/generic/unwind.h

${EGLIBC_SRC_ROOT}/libc/configure --prefix=/usr --enable-kernel=2.6.32 --with-cpu=power6 \
    --host=${TARGET_TRIPLET} --with-headers=${SYS_ROOT}/usr/include

/bin/rm -f ${SYS_ROOT}/usr/include/unwind.h
fakeroot make install_root=${SYS_ROOT} install-headers install-bootstrap-headers=yes

make csu/subdir_lib
install -m 0755 -d ${SYS_ROOT}/usr/lib
install -m 0644 -t ${SYS_ROOT}/usr/lib csu/crt1.o csu/crti.o csu/crtn.o
${SYS_ROOT}/usr/bin/${TARGET_TRIPLET}-gcc -nostdlib -nostartfiles -shared \
    -x c /dev/null -o ${SYS_ROOT}/usr/lib/libc.so

logger -t ${LOGGER_TAG} -s "Build eglibc (headers, crt?.o, dummy libc.so) success"

################ gcc - libgcc ################
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc

make -j${NR_JOBS} all-target-libgcc
make install-strip-target-libgcc
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (libgcc) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (libgcc) success"
/bin/rm -f ${SYS_ROOT}/usr/lib/libc.so

################ eglibc - full ################
cd  ${HOME}/obj/${TARGET_TRIPLET}/eglibc

make -j${NR_JOBS} ; fakeroot make install_root=${SYS_ROOT} install
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build eglibc (full) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build eglibc (full) success"

################ gcc - full ################
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (full) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (full) success"

logger -t ${LOGGER_TAG} -s "Build finished"

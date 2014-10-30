#!/bin/sh
#
# aarch64-linux-gcc -dM -E -  < /dev/null
# aarch64-linux-gcc -Werror -fstack-protector -xc /dev/null -S -o /dev/null
# path/to/src/configure --build=`/usr/share/misc/config.guess` --host=aarch64-linux --prefix=/tmp/aarch64-linux --disable-nls
#

export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-4_9-branch
export GLIBC_SRC_ROOT=${HOME}/src/glibc-2.20
export KERNEL_SRC_ROOT=${HOME}/src/linux-3.16.5
export BINUTILS_SRC_ROOT=${HOME}/src/binutils-2.24

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=aarch64-linux
export LOGGER_TAG=cross-arm64-gcc-4.9
export SYS_ROOT=${HOME}/cross/${TARGET_TRIPLET}
export PATH=${SYS_ROOT}/usr/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${HOME}/obj/${TARGET_TRIPLET}

################ Linux Kernel header files ################
cd ${KERNEL_SRC_ROOT}
make V=2 ARCH=arm64 alldefconfig
make V=2 ARCH=arm64 headers_check
make V=2 ARCH=arm64 INSTALL_HDR_PATH=${SYS_ROOT}/usr headers_install
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

################ gcc - mini ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/gcc-mini
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/gcc-mini
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc-mini

${GCC_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT}/usr \
    --with-sysroot=${SYS_ROOT} \
    --target=${TARGET_TRIPLET} \
    --enable-checking=release \
    --enable-languages=c --with-newlib --without-headers \
    --disable-multilib --disable-shared --disable-threads --disable-libssp --disable-libgomp \
    --disable-libmudflap --disable-libquadmath --disable-libatomic

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc (mini) failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (mini) success"

################ eglibc ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/eglibc
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/eglibc
cd  ${HOME}/obj/${TARGET_TRIPLET}/eglibc

${GLIBC_SRC_ROOT}/configure --prefix=/usr --enable-kernel=3.10.0 \
    --host=${TARGET_TRIPLET} --with-headers=${SYS_ROOT}/usr/include

fakeroot make install_root=${SYS_ROOT} install-headers install-bootstrap-headers=yes
make -j${NR_JOBS}
fakeroot make install_root=${SYS_ROOT} install
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build eglibc failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build eglibc success"

################ gcc - full ################
rm -fr ${HOME}/obj/${TARGET_TRIPLET}/gcc-full
mkdir -p ${HOME}/obj/${TARGET_TRIPLET}/gcc-full
cd  ${HOME}/obj/${TARGET_TRIPLET}/gcc-full

${GCC_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT}/usr \
    --with-sysroot=${SYS_ROOT} \
    --target=${TARGET_TRIPLET} \
    --enable-checking=release \
    --enable-languages=c,c++,fortran \
    --enable-fully-dynamic-string \
    --enable-libstdcxx-time=yes

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc - full failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (full) success"

logger -t ${LOGGER_TAG} -s "Build finished"

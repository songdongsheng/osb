#!/bin/sh
#
# http://en.wikipedia.org/wiki/Comparison_of_ARMv7-A_cores
#
# gcc -mfloat-abi=hard      -mcpu=cortex-a7      -mfpu=vfpv4      -mtune=cortex-a15.cortex-a7
#    --with-float=hard --with-cpu=cortex-a7 --with-fpu=vfpv4 --with-tune=cortex-a15.cortex-a7
#
# arm-linux-gnueabihf-gcc -dM -E -  < /dev/null
# arm-linux-gnueabihf-gcc -Werror -fstack-protector -xc /dev/null -S -o /dev/null
# path/to/src/configure --build=`/usr/share/misc/config.guess` --host=arm-linux-gnueabihf --prefix=/tmp/arm-linux-gnueabihf --disable-nls
#

export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-5-branch
export GLIBC_SRC_ROOT=${HOME}/src/glibc-2.24
export KERNEL_SRC_ROOT=${HOME}/src/linux-4.4.1
export BINUTILS_SRC_ROOT=${HOME}/src/binutils-2.26.1

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=arm-linux-gnueabihf
export LOGGER_TAG=cross-armhf-gcc-5
export SYS_ROOT=${HOME}/cross/${TARGET_TRIPLET}
export PATH=${SYS_ROOT}/usr/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${HOME}/obj/${TARGET_TRIPLET}

################ Linux Kernel header files ################
cd ${KERNEL_SRC_ROOT}
make V=2 ARCH=arm alldefconfig
make V=2 ARCH=arm headers_check
make V=2 ARCH=arm INSTALL_HDR_PATH=${SYS_ROOT}/usr headers_install
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
    --disable-libmudflap --disable-libquadmath --disable-libatomic \
    --with-cpu=cortex-a15 --with-float=hard --with-fpu=neon-vfpv4

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
    --enable-libstdcxx-time=yes \
    --disable-libsanitizer \
    --with-cpu=cortex-a15 --with-float=hard --with-fpu=neon-vfpv4

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc - full failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc (full) success"

logger -t ${LOGGER_TAG} -s "Build finished"

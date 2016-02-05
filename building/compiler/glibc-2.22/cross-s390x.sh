#!/bin/sh
#
# s390x-linux-gcc -dM -E -  < /dev/null
# s390x-linux-gcc -Werror -fstack-protector -xc /dev/null -S -o /dev/null
# path/to/src/configure --build=`/usr/share/misc/config.guess` --host=s390x-linux --prefix=/tmp/s390x-linux --disable-nls
#

export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-5-branch
export GLIBC_SRC_ROOT=${HOME}/src/glibc-2.22
export KERNEL_SRC_ROOT=${HOME}/src/linux-4.4.1
export BINUTILS_SRC_ROOT=${HOME}/src/binutils-2.26

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=s390x-linux
export LOGGER_TAG=cross-s390x-gcc-5
export SYS_ROOT=${HOME}/cross/${TARGET_TRIPLET}
export PATH=${SYS_ROOT}/usr/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${HOME}/obj/${TARGET_TRIPLET}

################ Linux Kernel header files ################
cd ${KERNEL_SRC_ROOT}

make V=2 ARCH=s390 defconfig
make V=2 ARCH=s390 headers_check
make V=2 ARCH=s390 INSTALL_HDR_PATH=${SYS_ROOT}/usr headers_install

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
    --enable-checking=release \
    --enable-languages=c,c++,fortran \
    --enable-fully-dynamic-string \
    --enable-libstdcxx-time=yes \
    --disable-multilib \
    --disable-libsanitizer \
    --with-arch=z10

make -j${NR_JOBS} all-gcc; make install-strip-gcc
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
install -m 0644 -t ${SYS_ROOT}/usr/include ${GLIBC_SRC_ROOT}/sysdeps/generic/unwind.h

${GLIBC_SRC_ROOT}/configure --prefix=/usr --enable-kernel=3.10.0 \
    --host=${TARGET_TRIPLET} --with-headers=${SYS_ROOT}/usr/include

/bin/rm -f ${SYS_ROOT}/usr/include/unwind.h
fakeroot make install_root=${SYS_ROOT} install-headers install-bootstrap-headers=yes

install -m 0755 -d ${SYS_ROOT}/usr/include/gnu
install -m 0644 -t ${SYS_ROOT}/usr/include/gnu ${GLIBC_SRC_ROOT}/include/gnu/stubs.h

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

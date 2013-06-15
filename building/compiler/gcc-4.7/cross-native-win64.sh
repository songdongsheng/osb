#!/bin/sh
#
# <prefix>-dlltool moldname-msvcrt.def -U --dllname msvcr90.dll
# lib32_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
# lib64_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
#
# sudo apt-get install texinfo libgmp-dev libmpfr-dev libmpc-dev
#

export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-4_7-branch
export MINGW_W64_SRC_ROOT=${HOME}/vcs/svn/mingw-w64/stable/v2.x

export ZLIB_SRC_ROOT=${HOME}/src/zlib-1.2.8
export EXPAT_SRC_ROOT=${HOME}/src/expat-2.1.0
export GMP_SRC_ROOT=${HOME}/src/gmp-5.1.2
export MPFR_SRC_ROOT=${HOME}/src/mpfr-3.1.2
export MPC_SRC_ROOT=${HOME}/src/mpc-1.0.1
export BINUTILS_SRC_ROOT=${HOME}/src/binutils-2.23.2
export GDB_SRC_ROOT=${HOME}/src/gdb-7.6
export MAKE_SRC_ROOT=${HOME}/src/make-3.82

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=x86_64-w64-mingw32
export LOGGER_TAG=native-win64-gcc47
export SYS_ROOT=${HOME}/native/gcc-4.7-win64
export SYS_3RD_ROOT=${HOME}/native/gcc-4.7-win64-3rd
export OBJ_ROOT=${HOME}/obj/native/gcc-4.7-win64
export PATH=${HOME}/cross/x86_64-windows-gcc47/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
################ cleanup ################
rm -fr ${SYS_ROOT} ${OBJ_ROOT} ${SYS_3RD_ROOT}

mkdir -p ${SYS_ROOT}/bin ${SYS_ROOT}/${TARGET_TRIPLET} ${SYS_3RD_ROOT}/lib ${SYS_3RD_ROOT}/include
cd ${SYS_ROOT} ; ln -s ${TARGET_TRIPLET} mingw

################ zlib ################
cd  ${ZLIB_SRC_ROOT}

${TARGET_TRIPLET}-windres --define GCC_WINDRES -o zlibrc.o win32/zlib1.rc
${TARGET_TRIPLET}-gcc -O2 -Ofast -shared -Wl,--out-implib,libz.dll.a  \
        -o zlib1.dll win32/zlib.def zlibrc.o adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c infback.c inffast.c inflate.c inftrees.c trees.c uncompr.c zutil.c
${TARGET_TRIPLET}-strip zlib1.dll

install -m 0755 -t ${SYS_ROOT}/bin zlib1.dll
install -m 0644 -t ${SYS_3RD_ROOT}/include zconf.h zlib.h
install -m 0644 -T zlib1.dll ${SYS_3RD_ROOT}/lib/libz.dll.a

################ expat ################
cd  ${EXPAT_SRC_ROOT}/lib

# add expat.rc files, add 2 exports to libexpat.def

${TARGET_TRIPLET}-windres --define GCC_WINDRES -o expat.rc.o expat.rc
${TARGET_TRIPLET}-gcc -DCOMPILED_FROM_DSP -DXML_ATTR_INFO -O2 -flto -s -shared -o expat.dll -Wl,--out-implib,libexpat.dll.a \
    libexpat.def expat.rc.o \
    xmlparse.c xmlrole.c xmltok.c xmltok_impl.c xmltok_ns.c

# ${TARGET_TRIPLET}-objdump -p expat.dll | less

install -m 0755 -t ${SYS_ROOT}/bin expat.dll
install -m 0644 -t ${SYS_3RD_ROOT}/include expat_external.h expat.h
install -m 0644 -T expat.dll ${SYS_3RD_ROOT}/lib/libexpat.dll.a

################ gmp ################
rm -fr ${OBJ_ROOT}/gmp
mkdir -p ${OBJ_ROOT}/gmp
cd  ${OBJ_ROOT}/gmp

${GMP_SRC_ROOT}/configure --prefix=${SYS_3RD_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --enable-cxx --disable-static --enable-shared

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gmp failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gmp success"

################ mpfr ################
rm -fr ${OBJ_ROOT}/mpfr
mkdir -p ${OBJ_ROOT}/mpfr
cd  ${OBJ_ROOT}/mpfr

${MPFR_SRC_ROOT}/configure --prefix=${SYS_3RD_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-static --enable-shared \
    --with-gmp=${SYS_3RD_ROOT}

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build mpfr failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build mpfr success"

################ mpc ################
rm -fr ${OBJ_ROOT}/mpc
mkdir -p ${OBJ_ROOT}/mpc
cd  ${OBJ_ROOT}/mpc

${MPC_SRC_ROOT}/configure --prefix=${SYS_3RD_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-static --enable-shared \
    --with-gmp=${SYS_3RD_ROOT} \
    --with-mpfr=${SYS_3RD_ROOT}

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build mpc failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build mpc success"

################ make ################
rm -fr ${OBJ_ROOT}/make
mkdir -p ${OBJ_ROOT}/make
cd  ${OBJ_ROOT}/make

${MAKE_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --host=${TARGET_TRIPLET} --build=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
    --disable-nls

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build make failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build make success"

################ gdb ################
rm -fr ${OBJ_ROOT}/gdb
mkdir -p ${OBJ_ROOT}/gdb
cd  ${OBJ_ROOT}/gdb

CFLAGS="-I${SYS_3RD_ROOT}/include" \
LDFLAGS="-L${SYS_3RD_ROOT}/lib" \
${GDB_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --host=${TARGET_TRIPLET} --build=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
    --disable-nls

make -j${NR_JOBS} ; make install
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gdb failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gdb success"

################ binutils ################
rm -fr ${OBJ_ROOT}/binutils
mkdir -p ${OBJ_ROOT}/binutils
cd  ${OBJ_ROOT}/binutils

# zlibVersion

CFLAGS="-I${SYS_3RD_ROOT}/include" \
LDFLAGS="-L${SYS_3RD_ROOT}/lib" \
${BINUTILS_SRC_ROOT}/configure --prefix=${SYS_ROOT} --with-sysroot=${SYS_ROOT} \
    --host=${TARGET_TRIPLET} --build=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
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

################ gcc ################
rm -fr ${OBJ_ROOT}/gcc
mkdir -p ${OBJ_ROOT}/gcc
cd  ${OBJ_ROOT}/gcc

${GCC_SRC_ROOT}/configure \
    --prefix=${SYS_ROOT} \
    --with-sysroot=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
    --enable-targets=all --disable-nls \
    --enable-checking=release --enable-languages=c,c++,fortran \
    --with-arch=x86-64 --with-tune=generic --with-fpmath=sse

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc success"

logger -t ${LOGGER_TAG} -s "Build finished"

install -m 0755 ${SYS_3RD_ROOT}/bin/*.dll ${SYS_ROOT}/bin/

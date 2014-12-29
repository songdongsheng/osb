#!/bin/sh
#
# <prefix>-dlltool moldname-msvcrt.def -U --dllname msvcr100.dll
# lib32_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
# lib64_libmoldname_a_AR = $(DTDEF32) $(top_srcdir)/lib32/moldname-msvcrt.def -U --dllname msvcrt.dll && $(AR) $(ARFLAGS)
#
# sudo apt-get install texinfo libexpat1-dev zlib1g-dev
#
# x86_64-w64-mingw32-gcc     -dM -E -  < /dev/null
# x86_64-w64-mingw32-gcc     -x c -shared -s -o t-w64.dll - < /dev/null
# x86_64-w64-mingw32-objdump -x t-w64.dll | grep -A 25 "The Export Tables"
#
# path/to/src/configure --build=`/usr/share/misc/config.guess` --host=x86_64-w64-mingw32 --prefix=/tmp/x86_64-w64-mingw32 --disable-nls
#

export BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
export GCC_SRC_ROOT=${HOME}/vcs/svn/gcc/branches/gcc-4_9-branch
export MINGW_W64_SRC_ROOT=${HOME}/vcs/git/mingw-w64-master

export GCC_DATE_STR=`cat ${GCC_SRC_ROOT}/gcc/DATESTAMP`
export GCC_BASE_VER=`cat ${GCC_SRC_ROOT}/gcc/BASE-VER`

export ZLIB_SRC_ROOT=${HOME}/src/zlib-1.2.8
export EXPAT_SRC_ROOT=${HOME}/src/expat-2.1.0
export BINUTILS_SRC_ROOT=${HOME}/src/binutils-2.24
export GDB_SRC_ROOT=${HOME}/src/gdb-7.8.1
export MAKE_SRC_ROOT=${HOME}/src/make-4.1

export NR_JOBS=`cat /proc/cpuinfo | grep '^processor\s*:' | wc -l`
export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=x86_64-w64-mingw32
export LOGGER_TAG=native-win64-gcc-4.9
export SYS_ROOT=${HOME}/native/gcc-4.9-win64
export SYS_3RD_ROOT=${HOME}/native/gcc-4.9-win64-3rd
export OBJ_ROOT=${HOME}/obj/native/gcc-4.9-win64
export PATH=${HOME}/cross/x86_64-windows-gcc-4.9/bin:${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

logger -t ${LOGGER_TAG} -s "Build started"
TMP_FILE=`mktemp`
cat << EOF | ${TARGET_TRIPLET}-g++ -s -O2 -o ${TMP_FILE} -x c++ - >/dev/null 2>&1
#include <iostream>
int main()
{
    std::cout << "Hello, world !" << std::endl;
    return 0;
}
EOF

if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build failed (${TARGET_TRIPLET}-g++ is not available)"
    exit 1
fi

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

logger -t ${LOGGER_TAG} -s "Build zlib success"

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

logger -t ${LOGGER_TAG} -s "Build expat success"

################ make ################
rm -fr ${OBJ_ROOT}/make
mkdir -p ${OBJ_ROOT}/make
cd  ${OBJ_ROOT}/make

${MAKE_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
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
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-nls --disable-werror

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
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --target=${TARGET_TRIPLET} \
    --disable-multilib --disable-nls --disable-werror

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

${MINGW_W64_SRC_ROOT}/mingw-w64-headers/configure --prefix=${SYS_ROOT}/${TARGET_TRIPLET} \
    --host=${TARGET_TRIPLET} --enable-sdk=all

make install
logger -t ${LOGGER_TAG} -s "Build mingw-w64 (header) success"

# ################ mingw-w64 CRT ################
rm -fr ${OBJ_ROOT}/mingw-w64-crt
mkdir -p ${OBJ_ROOT}/mingw-w64-crt
cd  ${OBJ_ROOT}/mingw-w64-crt

${MINGW_W64_SRC_ROOT}/mingw-w64-crt/configure --prefix=${SYS_ROOT}/${TARGET_TRIPLET} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --disable-lib32 --enable-wildcard

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
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --target=${TARGET_TRIPLET} \
    --disable-multilib --disable-nls --disable-win32-registry \
    --enable-checking=release --enable-languages=c,c++,fortran \
    --enable-fully-dynamic-string --with-arch=core2 --with-tune=generic

make -j${NR_JOBS} ; make install-strip
if [ $? -ne 0 ]; then
    logger -t ${LOGGER_TAG} -s "Build gcc failed"
    exit 1
fi
logger -t ${LOGGER_TAG} -s "Build gcc success"

logger -t ${LOGGER_TAG} -s "Build finished"

################ package ################
/bin/cp ${SYS_ROOT}/bin/make.exe ${SYS_ROOT}/bin/gmake.exe
/bin/cp ${SYS_ROOT}/bin/make.exe ${SYS_ROOT}/bin/mingw32-make.exe

rm -f ${SYS_ROOT}/mingw ${SYS_ROOT}/bin/${TARGET_TRIPLET}-gcc-${GCC_BASE_VER}.exe ${SYS_ROOT}/lib/libgcc_s_seh-1.dll

/bin/cp ${OBJ_ROOT}/gcc/${TARGET_TRIPLET}/libgcc/shlib/libgcc_s_seh-1.dll             \
        ${OBJ_ROOT}/gcc/${TARGET_TRIPLET}/libgfortran/.libs/libgfortran-3.dll         \
        ${OBJ_ROOT}/gcc/${TARGET_TRIPLET}/libquadmath/.libs/libquadmath-0.dll         \
        ${OBJ_ROOT}/gcc/${TARGET_TRIPLET}/libssp/.libs/libssp-0.dll                   \
        ${OBJ_ROOT}/gcc/${TARGET_TRIPLET}/libstdc++-v3/src/.libs/libstdc++-6.dll      ${SYS_ROOT}/bin/
#       libgomp/.libs/libgomp-1.dll                 ${SYS_ROOT}/bin/

${TARGET_TRIPLET}-strip \
    ${SYS_ROOT}/bin/*.exe \
    ${SYS_ROOT}/bin/*.dll \
    ${SYS_ROOT}/${TARGET_TRIPLET}/bin/*.exe \
    ${SYS_ROOT}/libexec/gcc/${TARGET_TRIPLET}/${GCC_BASE_VER}/*.exe \
    ${SYS_ROOT}/libexec/gcc/${TARGET_TRIPLET}/${GCC_BASE_VER}/*.dll

$BASE_DIR/version.sh "${SYS_ROOT}" "${GCC_SRC_ROOT}" "${MINGW_W64_SRC_ROOT}"
cd ${SYS_ROOT}/.. && bsdtar -c --format 7zip -f `basename ${SYS_ROOT}`_${GCC_BASE_VER}-$GCC_DATE_STR.7z `basename ${SYS_ROOT}`

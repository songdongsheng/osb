#!/bin/sh
#
# http://gcc.gnu.org/install/configure.html
# http://gcc.gnu.org/install/prerequisites.html
# http://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
# http://gcc.gnu.org/onlinedocs/gcc/i386-and-x86_002d64-Options.html
# http://gcc.gnu.org/onlinedocs/gcc/_005f_005fatomic-Builtins.html#
# http://gcc.gnu.org/onlinedocs/gcc/X86-Built_002din-Functions.html
#
# -std=c89, c99, c++98, c++0x
# -O2 -funroll-loops -ftree-vectorize
#
# --enable-targets=all vs --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32
# i686-w64-mingw32-windres --target=pe-x86-64 -o bzip2.rc.o bzip2.rc
# i686-w64-mingw32-windres --target=pe-i386 -o bzip2.rc.o bzip2.rc
# i686-w64-mingw32-gcc -print-multi-os-directory
#
# _WIN32, __MINGW32__, __MSVCRT__, __VERSION__, __i386__
#
# i686-w64-mingw32-gcc -march=x86-64 -mtune=generic -dM -E -  < /dev/null | sort
# i686-w64-mingw32-gcc -march=core2 -mno-sse3       -dM -E -  < /dev/null | sort
# i686-w64-mingw32-gcc -march=amdfam10 -mno-sse4a -mno-3dnow -mno-popcnt -mno-abm -dM -E -  < /dev/null | sort
#
# {"i686",          PROCESSOR_PENTIUMPRO,   CPU_PENTIUMPRO, 0},
# {"x86-64",        PROCESSOR_K8,           CPU_K8,         PTA_64BIT | PTA_MMX | PTA_SSE | PTA_SSE2 | PTA_NO_SAHF},
# {"core2",         PROCESSOR_CORE2_64,     CPU_CORE2,      PTA_64BIT | PTA_MMX | PTA_SSE | PTA_SSE2 | PTA_SSE3 | PTA_CX16 | PTA_SSSE3},
#
# export PATH=${HOME}/gcc-4.7-w32-linux/bin:/usr/sbin:/usr/bin:/sbin:/bin
# CFLAGS='-march=x86-64 -O2 -flto -pipe' CXXFLAGS='-march=x86-64 -O2 -flto -pipe' LDFLAGS='-s' \
# path/to/src/xz/configure --prefix=/tmp/w32 --host=i686-w64-mingw32 --disable-nls
# signtool sign /t http://timestamp.verisign.com/scripts/timstamp.dll grep.exe
#
# http://www.mpfr.org/mpfr-3.1.1/mpfr-3.1.1.tar.xz
# ftp://ftp.gnu.org/gnu/gmp/gmp-5.0.5.tar.xz
# http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz
#
# http://www.bastoul.net/cloog/pages/download/cloog-0.16.3.tar.gz
# http://bugseng.com/products/ppl/download/ftp/releases/0.12.1/ppl-0.12.1.tar.xz
#
# http://www.bastoul.net/cloog/pages/download/cloog-0.17.0.tar.gz
# http://www.grosser.es/files/cloog-0.17.0.tar.gz
#
# -------------------------------- Macro --------------------------------
export MAKE_FLAGS='-j4'

export CFLAGS='-march=x86-64 -O2 -pipe'
export CXXFLAGS='-march=x86-64 -O2 -pipe'
export LDFLAGS='-s'
#export LDFLAGS='-s -Wl,--large-address-aware'
#CFLAGS='-O2 -march=x86-64 -mtune=core2 -fomit-frame-pointer -momit-leaf-frame-pointer -fgraphite-identity -floop-interchange -floop-block -floop-parallelize-all'

export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export TARGET_TRIPLET=i686-w64-mingw32

export GDB_SOURCE_DIR=${HOME}/vcs/cvs/gdb
export GDB_SOURCE_DIR=${HOME}/vcs/git/gdb
export MAKE_SOURCE_DIR=${HOME}/vcs/cvs/make
export MAKE_SOURCE_DIR=${HOME}/src/make-3.82

export BINUTILS_SOURCE_DIR=${HOME}/vcs/cvs/binutils
export BINUTILS_SOURCE_DIR=${HOME}/vcs/git/binutils
export MINGW_W64_SOURCE_DIR=${HOME}/vcs/svn/mingw-w64/stable/v2.x
export GMP_SOURCE_DIR=${HOME}/src/gmp-5.0.5
export MPFR_SOURCE_DIR=${HOME}/src/mpfr-3.1.1
export MPC_SOURCE_DIR=${HOME}/src/mpc-1.0.1

# GCC 4.7 需要 ClooG 0.16.1+ (CLOOG_VERSION_MAJOR == 0 &&  CLOOG_VERSION_MINOR == 16 && CLOOG_VERSION_REVISION >= 1)
# GCC 4.7 需要 ppl 0.11+ (PPL_VERSION_MAJOR == 0 &&  PPL_VERSION_MINOR >= 11)


# GCC 4.8 需要 ClooG 0.17.0+ (CLOOG_VERSION_MAJOR == 0 &&  CLOOG_VERSION_MINOR == 17 && CLOOG_VERSION_REVISION >= 0)
# GCC 4.8 需要 ISL 0.10.0+ (#include <isl/version.h>; strncmp (isl_version (), "isl-0.10", strlen ("isl-0.10")) == 0)
export PPL_SOURCE_DIR=${HOME}/src/ppl-0.12.1
export CLOOG_SOURCE_DIR=${HOME}/src/cloog-0.16.3

export GCC_SOURCE_DIR=${HOME}/vcs/svn/gcc/branches/gcc-4_7-branch
export DATE_STR=`cat ${GCC_SOURCE_DIR}/gcc/DATESTAMP`
export BASE_VER=`cat ${GCC_SOURCE_DIR}/gcc/BASE-VER`

export CROSS_PREFIX=${HOME}/gcc-4.7-w32-linux
export CROSS_OBJ_ROOT=${HOME}/tmp/gcc-4.7-w32-linux-obj

export NATIVE_PREFIX=${HOME}/gcc-4.7-w32
export NATIVE_OBJ_ROOT=${HOME}/tmp/gcc-4.7-w32-obj

export PATH=${CROSS_PREFIX}/bin:${NATIVE_PREFIX}/bin:${NATIVE_PREFIX}/bin/64:/usr/sbin:/usr/bin:/sbin:/bin

# -------------------------------- Cleanup --------------------------------
rm -fr ${CROSS_OBJ_ROOT} ${CROSS_PREFIX} ${NATIVE_OBJ_ROOT} ${NATIVE_PREFIX}
mkdir -p  ${CROSS_PREFIX}/${TARGET_TRIPLET}/lib  ${CROSS_PREFIX}/${TARGET_TRIPLET}/lib64
mkdir -p ${NATIVE_PREFIX}/${TARGET_TRIPLET}/lib ${NATIVE_PREFIX}/${TARGET_TRIPLET}/lib64
mkdir -p  ${CROSS_PREFIX}/${TARGET_TRIPLET}/include  ${CROSS_PREFIX}/bin/64
mkdir -p ${NATIVE_PREFIX}/${TARGET_TRIPLET}/include ${NATIVE_PREFIX}/bin/64

cd ${CROSS_PREFIX}  && ln -sf ${TARGET_TRIPLET} mingw
cd ${NATIVE_PREFIX} && ln -sf ${TARGET_TRIPLET} mingw

<<COMMENT-COMMENT
# -------------------------------- ppl 0.12 --------------------------------
rm -fr ${HOME}/obj/ppl-0.12; mkdir -p ${HOME}/obj/ppl-0.12; cd ${HOME}/obj/ppl-0.12
${PPL_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq/ppl-0.12 --disable-shared --enable-interfaces="cxx c"
make -j4 && make install

# -------------------------------- CLooG 0.16 --------------------------------
rm -fr ${HOME}/obj/cloog-0.16; mkdir -p ${HOME}/obj/cloog-0.16; cd ${HOME}/obj/cloog-0.16
${CLOOG_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq/cloog-0.16 --disable-shared --with-isl=bundled
make -j4 && make install

COMMENT-COMMENT

# -------------------------------- Binutils --------------------------------
rm -fr ${CROSS_OBJ_ROOT}/binutils
mkdir -p ${CROSS_OBJ_ROOT}/binutils
cd ${CROSS_OBJ_ROOT}/binutils

${BINUTILS_SOURCE_DIR}/configure --prefix=${CROSS_PREFIX} --with-sysroot=${CROSS_PREFIX} \
    --host=${BUILD_TRIPLET} --build=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} \
    --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32 --disable-nls

make ${MAKE_FLAGS} && make install

# -------------------------------- mingw-w64-headers --------------------------------
rm -fr ${CROSS_OBJ_ROOT}/mingw-w64-header
mkdir -p ${CROSS_OBJ_ROOT}/mingw-w64-header
cd ${CROSS_OBJ_ROOT}/mingw-w64-header

${MINGW_W64_SOURCE_DIR}/mingw-w64-headers/configure --prefix=${CROSS_PREFIX} \
    --host=${TARGET_TRIPLET} --enable-sdk=all

make install

# -------------------------------- Core GCC --------------------------------
rm -fr ${CROSS_OBJ_ROOT}/gcc
mkdir -p ${CROSS_OBJ_ROOT}/gcc
cd ${CROSS_OBJ_ROOT}/gcc

${GCC_SOURCE_DIR}/configure --prefix=${CROSS_PREFIX} --with-sysroot=${CROSS_PREFIX} \
    --build=${BUILD_TRIPLET} --host=${BUILD_TRIPLET} --target=${TARGET_TRIPLET} --enable-targets=all \
    --with-fpmath=sse \
    --enable-checking=release --enable-languages=c,c++,fortran \
    --with-ppl=${HOME}/gcc-preq/ppl-0.12 --with-cloog=${HOME}/gcc-preq/cloog-0.16 --enable-cloog-backend=isl

make ${MAKE_FLAGS} all-gcc && make install-gcc

# -------------------------------- mingw-w64 CRT --------------------------------
rm -fr ${CROSS_OBJ_ROOT}/mingw-w64-crt
mkdir -p ${CROSS_OBJ_ROOT}/mingw-w64-crt
cd ${CROSS_OBJ_ROOT}/mingw-w64-crt

CC=i686-w64-mingw32-gcc CXX=i686-w64-mingw32-g++ \
${MINGW_W64_SOURCE_DIR}/mingw-w64-crt/configure --prefix=${CROSS_PREFIX} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --enable-lib32 --enable-lib64 --enable-wildcard

make ${MAKE_FLAGS} && make install

# goto gcc
# make ${MAKE_FLAGS} all-target-libgcc
# make install-target-libgcc
# goto thread support

# -------------------------------- finally --------------------------------
cd ${CROSS_OBJ_ROOT}/gcc

make ${MAKE_FLAGS} && make install


# ================================ mingw-w64-headers ================================
rm -fr ${NATIVE_OBJ_ROOT}/mingw-w64-header
mkdir -p ${NATIVE_OBJ_ROOT}/mingw-w64-header
cd ${NATIVE_OBJ_ROOT}/mingw-w64-header

${MINGW_W64_SOURCE_DIR}/mingw-w64-headers/configure --prefix=${NATIVE_PREFIX} \
    --host=${TARGET_TRIPLET} --enable-sdk=all

make install

# ================================ mingw-w64 CRT ================================
rm -fr ${NATIVE_OBJ_ROOT}/mingw-w64-crt
mkdir -p ${NATIVE_OBJ_ROOT}/mingw-w64-crt
cd ${NATIVE_OBJ_ROOT}/mingw-w64-crt

CC=${CROSS_PREFIX}/bin/${TARGET_TRIPLET}-gcc \
${MINGW_W64_SOURCE_DIR}/mingw-w64-crt/configure --prefix=${NATIVE_PREFIX} \
    --build=${BUILD_TRIPLET}  --host=${TARGET_TRIPLET} --enable-lib32 --enable-lib64

make ${MAKE_FLAGS} && make install

# ================================ native gmp ================================
rm -fr ${NATIVE_OBJ_ROOT}/gmp
mkdir -p ${NATIVE_OBJ_ROOT}/gmp
cd ${NATIVE_OBJ_ROOT}/gmp

${GMP_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq-w32/gmp-5.0 \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --enable-cxx --disable-shared

make ${MAKE_FLAGS} && make install

# ================================ native mpfr ================================
rm -fr ${NATIVE_OBJ_ROOT}/mpfr
mkdir -p ${NATIVE_OBJ_ROOT}/mpfr
cd ${NATIVE_OBJ_ROOT}/mpfr

${MPFR_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq-w32/mpfr-3.1 \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-shared \
    --with-gmp=${HOME}/gcc-preq-w32/gmp-5.0

make ${MAKE_FLAGS} && make install

# ================================ native mpc ================================
rm -fr ${NATIVE_OBJ_ROOT}/mpc
mkdir -p ${NATIVE_OBJ_ROOT}/mpc
cd ${NATIVE_OBJ_ROOT}/mpc

${MPC_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq-w32/mpc-1.0 \
    -build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-shared \
    --with-gmp=${HOME}/gcc-preq-w32/gmp-5.0 \
    --with-mpfr=${HOME}/gcc-preq-w32/mpfr-3.1

make ${MAKE_FLAGS} && make install

# ================================ ppl 0.12 ================================
rm -fr ${NATIVE_OBJ_ROOT}/ppl
mkdir -p ${NATIVE_OBJ_ROOT}/ppl
cd ${NATIVE_OBJ_ROOT}/ppl

${PPL_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq-w32/ppl-0.12 \
    -build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-shared \
    --enable-interfaces="cxx c" \
    --with-gmp=${HOME}/gcc-preq-w32/gmp-5.0

make ${MAKE_FLAGS} && make install

# ================================ CLooG 0.16 ================================
rm -fr ${NATIVE_OBJ_ROOT}/cloog
mkdir -p ${NATIVE_OBJ_ROOT}/cloog
cd ${NATIVE_OBJ_ROOT}/cloog

${CLOOG_SOURCE_DIR}/configure --prefix=${HOME}/gcc-preq-w32/cloog-0.16 \
    -build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-shared -with-isl=bundled \
    --with-gmp-prefix=${HOME}/gcc-preq-w32/gmp-5.0

make ${MAKE_FLAGS} && make install

# ================================ build gdb ================================
rm -fr ${NATIVE_OBJ_ROOT}/gdb
mkdir -p ${NATIVE_OBJ_ROOT}/gdb
cd ${NATIVE_OBJ_ROOT}/gdb

${GDB_SOURCE_DIR}/configure --prefix=${NATIVE_PREFIX} \
    --build=${BUILD_TRIPLET}  --host=${TARGET_TRIPLET}  --disable-nls

make ${MAKE_FLAGS} && make install

find . -name *.exe -exec cp {} ${NATIVE_PREFIX}/bin/ \;

# ================================ build make ================================
rm -fr ${NATIVE_OBJ_ROOT}/make
mkdir -p ${NATIVE_OBJ_ROOT}/make
cd ${NATIVE_OBJ_ROOT}/make

${MAKE_SOURCE_DIR}/configure --prefix=${NATIVE_PREFIX} \
    --build=${BUILD_TRIPLET}  --host=${TARGET_TRIPLET} --disable-nls

make ${MAKE_FLAGS} && make install

# ================================ native binutils ================================
rm -fr ${NATIVE_OBJ_ROOT}/binutils
mkdir -p ${NATIVE_OBJ_ROOT}/binutils
cd ${NATIVE_OBJ_ROOT}/binutils

${BINUTILS_SOURCE_DIR}/configure --prefix=${NATIVE_PREFIX} --with-sysroot=${CROSS_PREFIX} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --target=${TARGET_TRIPLET} \
    --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32 --disable-nls

make ${MAKE_FLAGS} && make install

# ================================ native GCC ================================
rm -fr ${NATIVE_OBJ_ROOT}/gcc
mkdir -p ${NATIVE_OBJ_ROOT}/gcc
cd ${NATIVE_OBJ_ROOT}/gcc

${GCC_SOURCE_DIR}/configure --prefix=${NATIVE_PREFIX} --with-sysroot=${NATIVE_PREFIX} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} --target=${TARGET_TRIPLET} --enable-targets=all \
    --with-fpmath=sse \
    --enable-checking=release --enable-languages=c,c++,fortran --disable-win32-registry \
    --with-gmp=${HOME}/gcc-preq-w32/gmp-5.0 --with-mpfr=${HOME}/gcc-preq-w32/mpfr-3.1 --with-mpc=${HOME}/gcc-preq-w32/mpc-1.0 \
    --with-ppl=${HOME}/gcc-preq-w32/ppl-0.12 --with-cloog=${HOME}/gcc-preq-w32/cloog-0.16 \
    --enable-cloog-backend=isl --with-host-libstdcxx='-lstdc++'

make ${MAKE_FLAGS} && make install

/bin/rm -fr ${NATIVE_PREFIX}/mingw ${NATIVE_PREFIX}/bin/*${BASE_VER}* ${NATIVE_PREFIX}/share/locale \
        ${NATIVE_PREFIX}/lib/*.dll ${NATIVE_PREFIX}/lib64/*.dll \
        ${NATIVE_PREFIX}/${TARGET_TRIPLET}/lib/*.dll ${NATIVE_PREFIX}/${TARGET_TRIPLET}/lib64/*.dll

cd ${NATIVE_OBJ_ROOT}/gcc/${TARGET_TRIPLET}
/bin/cp 64/libgcc/64/shlib/libgcc_s_sjlj-1.dll      \
        64/libgfortran/.libs/libgfortran-3.dll      \
        64/libgomp/.libs/libgomp-1.dll              \
        64/libquadmath/.libs/libquadmath-0.dll      \
        64/libssp/.libs/libssp-0.dll                \
        64/libstdc++-v3/src/.libs/libstdc++-6.dll   ${NATIVE_PREFIX}/bin/64/

/bin/cp libgcc/shlib/libgcc_s_sjlj-1.dll            \
        libgfortran/.libs/libgfortran-3.dll         \
        libgomp/.libs/libgomp-1.dll                 \
        libquadmath/.libs/libquadmath-0.dll         \
        libssp/.libs/libssp-0.dll                   \
        libstdc++-v3/src/.libs/libstdc++-6.dll      ${NATIVE_PREFIX}/bin/

${CROSS_PREFIX}/bin/${TARGET_TRIPLET}-strip \
    ${NATIVE_PREFIX}/bin/*.exe \
    ${NATIVE_PREFIX}/bin/*.dll \
    ${NATIVE_PREFIX}/bin/64/*.dll \
    ${NATIVE_PREFIX}/${TARGET_TRIPLET}/bin/*.exe \
    ${NATIVE_PREFIX}/libexec/gcc/${TARGET_TRIPLET}/${BASE_VER}/*.exe \
    ${NATIVE_PREFIX}/libexec/gcc/${TARGET_TRIPLET}/${BASE_VER}/*.dll

/bin/cp ${NATIVE_PREFIX}/bin/make.exe ${NATIVE_PREFIX}/bin/gmake.exe
/bin/cp ${NATIVE_PREFIX}/bin/make.exe ${NATIVE_PREFIX}/bin/mingw32-make.exe

if [ -f ${HOME}/version.txt ]; then
    /bin/cp ${HOME}/version.txt ${NATIVE_PREFIX}/
fi

exit 0

########################################################################
cd ${NATIVE_PREFIX}/../ && tar -c gcc-4.7-w32 | xz -vz9 > ${HOME}/gcc-${BASE_VER}-w32_${DATE_STR}.tar.xz
########################################################################
python ${HOME}/googlecode_upload.py \
        -s "gcc 4.7 for windows xp/2003 or later - multilib (32 bit executable files)" \
        -p "i18n-zh" \
        -l "gcc, OpSys-Windows, Type-Executable, 32bit" \
        -u dongsheng.song -w rD4Ny3nV8ES8 \
        ${HOME}/gcc-${BASE_VER}-w32_${DATE_STR}.tar.xz
########################################################################

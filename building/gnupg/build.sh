#-------------------------------- gnupg --------------------------------
: '
GnuPG 2.1 depends on the following packages:

ftp://ftp.gnupg.org/GnuPG/libgpg-error/libgpg-error-1.19.tar.bz2
ftp://ftp.gnupg.org/GnuPG/npth/npth-1.2.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libksba/libksba-1.3.3.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.2.1.tar.bz2
ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-0.9.4.tar.bz2
ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.1.5.tar.bz2
'
#-------------------------------- prepare --------------------------------
export TARGET_TRIPLET=i686-w64-mingw32
export TARGET_TRIPLET=x86_64-w64-mingw32

export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export SYS_ROOT=${HOME}/native/${TARGET_TRIPLET}/gnupg-2.1
export OBJ_ROOT=${HOME}/obj/x${TARGET_TRIPLET}/gnupg-2.1

export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH=${HOME}/cross/i686-windows-gcc-5/bin:${PATH}
export PATH=${HOME}/cross/x86_64-windows-gcc-5/bin:${PATH}
export PATH=${SYS_ROOT}/bin:${PATH}

rm -fr ${SYS_ROOT} ${OBJ_ROOT}

mkdir -p ${OBJ_ROOT} ; cd ${OBJ_ROOT}

tar -xjf ~/sync/building/src/gnupg-2.1.5.tar.bz2
tar -xjf ~/sync/building/src/libassuan-2.2.1.tar.bz2
tar -xjf ~/sync/building/src/libgcrypt-1.6.3.tar.bz2
tar -xjf ~/sync/building/src/libgpg-error-1.19.tar.bz2
tar -xzf ~/sync/building/src/libiconv-1.14.tar.gz
tar -xjf ~/sync/building/src/libksba-1.3.3.tar.bz2
tar -xjf ~/sync/building/src/npth-1.2.tar.bz2
tar -xjf ~/sync/building/src/pcre-8.37.tar.bz2
tar -xjf ~/sync/building/src/pinentry-0.9.4.tar.bz2
tar -xzf ~/sync/building/src/zlib-1.2.8.tar.gz

export GNUPG_SRC_ROOT=${OBJ_ROOT}/gnupg-2.1.5
export LIBASSUAN_SRC_ROOT=${OBJ_ROOT}/libassuan-2.2.1
export LIBGCRYPT_SRC_ROOT=${OBJ_ROOT}/libgcrypt-1.6.3
export LIBGPG_ERROR_SRC_ROOT=${OBJ_ROOT}/libgpg-error-1.19
export LIBICONV_SRC_ROOT=${OBJ_ROOT}/libiconv-1.14
export LIBKSBA_SRC_ROOT=${OBJ_ROOT}/libksba-1.3.3
export NPTH_SRC_ROOT=${OBJ_ROOT}/npth-1.2
export PCRF_SRC_ROOT=${OBJ_ROOT}/pcre-8.37
export PINENTRY_SRC_ROOT=${OBJ_ROOT}/pinentry-0.9.4
export ZLIB_SRC_ROOT=${OBJ_ROOT}/zlib-1.2.8

#-------------------------------- x86_64-w64-mingw32-pkg-config --------------------------------
mkdir -p ${SYS_ROOT}/bin && cat > ${SYS_ROOT}/bin/${TARGET_TRIPLET}-pkg-config <<EOF
#!/bin/sh
export PKG_CONFIG_LIBDIR=${SYS_ROOT}/lib/pkgconfig
/usr/bin/pkg-config --define-variable=prefix=${SYS_ROOT} \$@
EOF
chmod +x ${SYS_ROOT}/bin/${TARGET_TRIPLET}-pkg-config

#-------------------------------- zlib --------------------------------
cd $ZLIB_SRC_ROOT
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o adler32.o adler32.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o compress.o compress.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o crc32.o crc32.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o deflate.o deflate.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o gzclose.o gzclose.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o gzlib.o gzlib.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o gzread.o gzread.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o gzwrite.o gzwrite.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o infback.o infback.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o inffast.o inffast.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o inflate.o inflate.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o inftrees.o inftrees.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o trees.o trees.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o uncompr.o uncompr.c
${TARGET_TRIPLET}-gcc  -O3 -Wall -c -o zutil.o zutil.c

${TARGET_TRIPLET}-ar rcs libz.a adler32.o compress.o crc32.o deflate.o gzclose.o gzlib.o gzread.o gzwrite.o infback.o inffast.o inflate.o inftrees.o trees.o uncompr.o zutil.o
${TARGET_TRIPLET}-windres --define GCC_WINDRES -o zlibrc.o win32/zlib1.rc
${TARGET_TRIPLET}-gcc -shared -Wl,--out-implib,libz.dll.a -o zlib1.dll win32/zlib.def adler32.o compress.o crc32.o deflate.o gzclose.o gzlib.o gzread.o gzwrite.o infback.o inffast.o inflate.o inftrees.o trees.o uncompr.o zutil.o  zlibrc.o
${TARGET_TRIPLET}-strip zlib1.dll

install -m 0755 -d ${SYS_ROOT}/bin ${SYS_ROOT}/lib ${SYS_ROOT}/include
install -m 0755 -t ${SYS_ROOT}/bin zlib1.dll
install -m 0644 -t ${SYS_ROOT}/include zconf.h zlib.h
install -m 0644 -t ${SYS_ROOT}/lib libz.a
install -m 0644 -T zlib1.dll ${SYS_ROOT}/lib/libz.dll.a

#-------------------------------- pcre --------------------------------
cd ${PCRF_SRC_ROOT} && ${PCRF_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-cpp --enable-utf --disable-shared --enable-static

make -j8; make install-strip

cat > ${SYS_ROOT}/include/regex.h <<EOF
#ifndef PCRE_STATIC
#define PCRE_STATIC 1
#endif

#include <pcreposix.h>
EOF

rm -fr ${SYS_ROOT}/lib/regex ; mkdir ${SYS_ROOT}/lib/regex ; cd ${SYS_ROOT}/lib/regex
${TARGET_TRIPLET}-ar x ../libpcre.a
${TARGET_TRIPLET}-ar x ../libpcreposix.a
${TARGET_TRIPLET}-ar q ../libregex.a *.o
rm -fr ${SYS_ROOT}/lib/regex

#-------------------------------- libiconv --------------------------------
cd ${LIBICONV_SRC_ROOT} && ${LIBICONV_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install-strip

#-------------------------------- pinentry --------------------------------
cd ${PINENTRY_SRC_ROOT} && ${PINENTRY_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-ncurses --disable-pinentry-tty

make -j8; install -m 0755 -t ${SYS_ROOT}/bin w32/pinentry-w32.exe

#-------------------------------- libgpg-error --------------------------------
cd ${LIBGPG_ERROR_SRC_ROOT} && ${LIBGPG_ERROR_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install-strip

#-------------------------------- npth --------------------------------
cd ${NPTH_SRC_ROOT} && ${NPTH_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install-strip

#-------------------------------- libgcrypt --------------------------------
cd ${LIBGCRYPT_SRC_ROOT} && ${LIBGCRYPT_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-asm --disable-padlock-support

make -j8; make install-strip

#-------------------------------- libksba --------------------------------
cd ${LIBKSBA_SRC_ROOT} && ${LIBKSBA_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install-strip

#-------------------------------- libassuan --------------------------------
cd ${LIBASSUAN_SRC_ROOT} && ${LIBASSUAN_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install-strip

#-------------------------------- gnupg --------------------------------
cd ${GNUPG_SRC_ROOT} && ${GNUPG_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-card-support --disable-ccid-driver --disable-scdaemon \
    --disable-g13 --disable-gpgtar \
    --with-zlib=${SYS_ROOT} --with-regex=${SYS_ROOT}

make -j8; make install-strip

${TARGET_TRIPLET}-strip ${SYS_ROOT}/bin/*.dll ${SYS_ROOT}/bin/*.exe ${SYS_ROOT}/libexec/*.exe

: '
gnupg-2.1/bin/libassuan6-0.dll
gnupg-2.1/bin/libgcrypt-20.dll
gnupg-2.1/bin/libgpg-error6-0.dll
gnupg-2.1/bin/libiconv-2.dll
gnupg-2.1/bin/libksba-8.dll
gnupg-2.1/bin/libnpth6-0.dll
gnupg-2.1/bin/zlib1.dll
gnupg-2.1/bin/dirmngr.exe
gnupg-2.1/bin/dirmngr-client.exe
gnupg-2.1/bin/gpg2.exe
gnupg-2.1/bin/gpg-agent.exe
gnupg-2.1/bin/gpgconf.exe
gnupg-2.1/bin/gpg-connect-agent.exe
gpg-error.exe
gnupg-2.1/bin/gpgkey2ssh.exe
gnupg-2.1/bin/gpgsm.exe
gnupg-2.1/bin/gpgv2.exe
hmac256.exe
iconv.exe
gnupg-2.1/bin/kbxutil.exe
gnupg-2.1/bin/pinentry-w32.exe
gnupg-2.1/libexec/gpg-check-pattern.exe
gnupg-2.1/libexec/gpg-preset-passphrase.exe
gnupg-2.1/libexec/gpg-protect-tool.exe
'
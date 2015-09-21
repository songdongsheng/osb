#-------------------------------- gnupg --------------------------------
: '
GnuPG 2.1 depends on the following packages:

ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.1.8.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.3.0.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.4.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libksba/libksba-1.3.3.tar.bz2
ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-0.9.6.tar.bz2
ftp://ftp.gnupg.org/GnuPG/libgpg-error/libgpg-error-1.20.tar.bz2
ftp://ftp.gnupg.org/GnuPG/npth/npth-1.2.tar.bz2

http://zlib.net/zlib-1.2.8.tar.gz
http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz

http://download.sourceforge.net/pcre/pcre-8.37.tar.bz2
http://download.sourceforge.net/pcre/pcre2-10.20.tar.bz2
'
#-------------------------------- prepare --------------------------------
export TARGET_TRIPLET=i686-w64-mingw32
export TARGET_TRIPLET=x86_64-w64-mingw32

export BUILD_TRIPLET=`/usr/share/misc/config.guess`
export SYS_ROOT=${HOME}/native/${TARGET_TRIPLET}/gnupg-2.1
export OBJ_ROOT=${HOME}/obj/${TARGET_TRIPLET}/gnupg-2.1

export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH=${HOME}/cross/i686-windows-gcc-5/bin:${PATH}
export PATH=${HOME}/cross/x86_64-windows-gcc-5/bin:${PATH}
export PATH=${SYS_ROOT}/bin:${PATH}

export GNUPG_SRC_ROOT=${OBJ_ROOT}/gnupg-2.1.8
export LIBASSUAN_SRC_ROOT=${OBJ_ROOT}/libassuan-2.3.0
export LIBGCRYPT_SRC_ROOT=${OBJ_ROOT}/libgcrypt-1.6.4
export LIBGCRYPT_SRC_ROOT=/home/cauchy/vcs/git/libgcrypt
export LIBGPG_ERROR_SRC_ROOT=${OBJ_ROOT}/libgpg-error-1.20
export LIBICONV_SRC_ROOT=${OBJ_ROOT}/libiconv-1.14
export LIBKSBA_SRC_ROOT=${OBJ_ROOT}/libksba-1.3.3
export NPTH_SRC_ROOT=${OBJ_ROOT}/npth-1.2
export PCRF_SRC_ROOT=${OBJ_ROOT}/pcre-8.37
export PINENTRY_SRC_ROOT=${OBJ_ROOT}/pinentry-0.9.6
#export PINENTRY_SRC_ROOT=/home/cauchy/vcs/git/pinentry
export ZLIB_SRC_ROOT=${OBJ_ROOT}/zlib-1.2.8

rm -fr ${SYS_ROOT} ${OBJ_ROOT}

mkdir -p ${OBJ_ROOT} ; cd ${OBJ_ROOT}

tar -xjf ~/sync/building/src/gnupg-2.1.8.tar.bz2
tar -xjf ~/sync/building/src/libassuan-2.3.0.tar.bz2
tar -xjf ~/sync/building/src/libgcrypt-1.6.4.tar.bz2
tar -xjf ~/sync/building/src/libgpg-error-1.20.tar.bz2
tar -xzf ~/sync/building/src/libiconv-1.14.tar.gz
tar -xjf ~/sync/building/src/libksba-1.3.3.tar.bz2
tar -xjf ~/sync/building/src/npth-1.2.tar.bz2
tar -xjf ~/sync/building/src/pcre-8.37.tar.bz2
tar -xjf ~/sync/building/src/pinentry-0.9.6.tar.bz2
tar -xzf ~/sync/building/src/zlib-1.2.8.tar.gz

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

make -j8; make install

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

make -j8; make install

#-------------------------------- npth --------------------------------
cd ${NPTH_SRC_ROOT} && ${NPTH_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install

#-------------------------------- libgpg-error --------------------------------
cd ${LIBGPG_ERROR_SRC_ROOT} && ${LIBGPG_ERROR_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install

#-------------------------------- libgcrypt --------------------------------
cd ${LIBGCRYPT_SRC_ROOT} && ${LIBGCRYPT_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-asm --disable-padlock-support --disable-doc

# SUBDIRS

make clean; make -j8; make install

#-------------------------------- libksba --------------------------------
cd ${LIBKSBA_SRC_ROOT} && ${LIBKSBA_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install

#-------------------------------- libassuan --------------------------------
cd ${LIBASSUAN_SRC_ROOT} && ${LIBASSUAN_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make -j8; make install

#-------------------------------- pinentry --------------------------------
cd ${PINENTRY_SRC_ROOT} && ${PINENTRY_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

# m4_define([mym4_revision], [1532bf3])

make clean; make -j8; make install

#-------------------------------- gnupg --------------------------------
cd ${GNUPG_SRC_ROOT} && ${GNUPG_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-card-support --disable-ccid-driver --disable-scdaemon \
    --disable-g13 --disable-gpgtar \
    --with-zlib=${SYS_ROOT} --with-regex=${SYS_ROOT}

make -j8; make install

# ${TARGET_TRIPLET}-strip ${SYS_ROOT}/bin/*.dll ${SYS_ROOT}/bin/*.exe ${SYS_ROOT}/libexec/*.exe

: '
-rwxr-xr-x 1 cauchy cauchy  688192 Aug 12 17:09 libassuan6-0.dll
-rwxr-xr-x 1 cauchy cauchy 4270456 Aug 12 17:09 libgcrypt-20.dll
-rwxr-xr-x 1 cauchy cauchy  533046 Aug 12 17:09 libgpg-error6-0.dll
-rwxr-xr-x 1 cauchy cauchy 1538877 Aug 12 17:09 libiconv-2.dll
-rwxr-xr-x 1 cauchy cauchy 1200416 Aug 12 17:09 libksba-8.dll
-rwxr-xr-x 1 cauchy cauchy  184690 Aug 12 17:09 libnpth6-0.dll
-rwxr-xr-x 1 cauchy cauchy  114176 Aug 12 17:09 zlib1.dll

-rwxr-xr-x 1 cauchy cauchy  382583 Aug 12 17:24 dirmngr-client.exe
-rwxr-xr-x 1 cauchy cauchy 1723647 Aug 12 17:24 dirmngr.exe
-rwxr-xr-x 1 cauchy cauchy 1618019 Aug 12 17:24 gpg-agent.exe
-rwxr-xr-x 1 cauchy cauchy  502759 Aug 12 17:24 gpgconf.exe
-rwxr-xr-x 1 cauchy cauchy  649204 Aug 12 17:24 gpg-connect-agent.exe
-rwxr-xr-x 1 cauchy cauchy  167571 Aug 12 17:24 gpg-error.exe
-rwxr-xr-x 1 cauchy cauchy 4254011 Aug 12 17:24 gpg.exe
-rwxr-xr-x 1 cauchy cauchy 2240886 Aug 12 17:24 gpgsm.exe
-rwxr-xr-x 1 cauchy cauchy  241406 Aug 12 17:24 hmac256.exe
-rwxr-xr-x 1 cauchy cauchy  208186 Aug 12 17:24 iconv.exe
-rwxr-xr-x 1 cauchy cauchy  739264 Aug 12 17:24 kbxutil.exe
-rwxr-xr-x 1 cauchy cauchy  261844 Aug 12 17:24 pinentry.exe

cp  libassuan*.dll libgcrypt*.dll libgpg-error*.dll \
    libiconv*.dll libksba*.dll libnpth*.dll zlib1.dll \
    dirmngr.exe dirmngr-client.exe gpg-agent.exe gpgconf.exe \
    gpg-connect-agent.exe gpg-error.exe gpg2.exe gpgv2.exe gpgsm.exe \
    hmac256.exe iconv.exe kbxutil.exe pinentry-w32.exe xxx/

${TARGET_TRIPLET}-strip *.exe *.dll ; cp gpg2.exe gpg.exe; cp gpgv2.exe gpgv.exe

$ cat > version.txt <<EOF
gnupg-2.1.8

libgcrypt-1.7.0-g3a3d541
pinentry-0.9.6

libassuan-2.3.0
libgpg-error-1.19
libiconv-1.14
libksba-1.3.3
npth-1.2
pcre-8.37
zlib-1.2.8
EOF

7z a -t7z -mx9 -ssc -mtc=on -mmt=on -m0=LZMA2 gnupg-2.1.8-w32.7z gnupg-2.1.8-w32/
7z a -t7z -mx9 -ssc -mtc=on -mmt=on -m0=LZMA2 gnupg-2.1.8-w64.7z gnupg-2.1.8-w64/

cd %USERPROFILE%\AppData\Roaming\gnupg
echo Exit Code is %errorlevel%
HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor\Autorun to @chcp 65001>nul

gpg --delete-secret-and-public-keys

$env:Path = "D:\opt\gnupg-2.1.8-w32;" + $env:Path

SET PATH=D:\opt\gnupg-2.1.8-w32

gpg-agent --debug-level expert --daemon

gpg-connect-agent <<EOT
GETINFO pid
GETINFO version
GET_CONFIRMATION Hello
EOT

gpg --import D:\opt\putty-0.65\ob\0x46D397FF-sec.asc
gpg --refresh-keys
gpg --edit-key 46D397FF
gpg --list-keys
gpg --list-secret-keys
gpg -sab .gitconfig
gpg --verify .gitconfig.asc
'

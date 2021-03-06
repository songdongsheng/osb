#-------------------------------- gnupg --------------------------------
: '
http://unbound.net/documentation/libunbound.html

GnuPG 2.1 depends on the following packages:

ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.1.15.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.4.3.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.7.3.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.24.tar.bz2
ftp://ftp.gnupg.org/gcrypt/libksba/libksba-1.3.5.tar.bz2
ftp://ftp.gnupg.org/gcrypt/npth/npth-1.2.tar.bz2
ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-0.9.7.tar.bz2

ftp://ftp.g10code.com/g10code/adns/adns-1.4-g10-7.tar.bz2
https://www.sqlite.org/2016/sqlite-amalgamation-3140200.zip

https://git.gnupg.org/adns.git  [adns-1.4-g10-7, c363fb22d3ce24552ab97572e348d2b024a9f16a]
https://github.com/gpg/adns.git [adns-1.4-g10-7, c363fb22d3ce24552ab97572e348d2b024a9f16a]
git archive -9 --prefix adns-1.4-g10-7/ -o ~/adns-1.4-g10-7.tar.bz2 c363fb22d3ce24552ab97572e348d2b024a9f16a

http://zlib.net/zlib-1.2.8.tar.gz
https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz

http://download.sourceforge.net/pcre/pcre-8.39.tar.bz2
http://download.sourceforge.net/pcre/pcre2-10.22.tar.bz2
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

export GNUPG_SRC_ROOT=${OBJ_ROOT}/gnupg-2.1.15
#export GNUPG_SRC_ROOT=${HOME}/vcs/git/gnupg
export LIBASSUAN_SRC_ROOT=${OBJ_ROOT}/libassuan-2.4.3
export LIBGCRYPT_SRC_ROOT=${OBJ_ROOT}/libgcrypt-1.7.3
export LIBGPG_ERROR_SRC_ROOT=${OBJ_ROOT}/libgpg-error-1.24
export LIBICONV_SRC_ROOT=${OBJ_ROOT}/libiconv-1.14
export LIBKSBA_SRC_ROOT=${OBJ_ROOT}/libksba-1.3.5
export NPTH_SRC_ROOT=${OBJ_ROOT}/npth-1.2
export PCRF_SRC_ROOT=${OBJ_ROOT}/pcre-8.39
export PINENTRY_SRC_ROOT=${OBJ_ROOT}/pinentry-0.9.7
#export PINENTRY_SRC_ROOT=${HOME}/vcs/git/pinentry
export ZLIB_SRC_ROOT=${OBJ_ROOT}/zlib-1.2.8
export ADNS_SRC_ROOT=${OBJ_ROOT}/adns-1.4-g10-7
export SQLITE3_SRC_ROOT=${OBJ_ROOT}/sqlite-amalgamation-3140200

rm -fr ${SYS_ROOT} ${OBJ_ROOT}

mkdir -p ${OBJ_ROOT} ; cd ${OBJ_ROOT}

tar -xjf ~/sync/building/src/gnupg-2.1.15.tar.bz2
tar -xjf ~/sync/building/src/libassuan-2.4.3.tar.bz2
tar -xjf ~/sync/building/src/libgcrypt-1.7.3.tar.bz2
tar -xjf ~/sync/building/src/libgpg-error-1.24.tar.bz2
tar -xzf ~/sync/building/src/libiconv-1.14.tar.gz
tar -xjf ~/sync/building/src/libksba-1.3.5.tar.bz2
tar -xjf ~/sync/building/src/npth-1.2.tar.bz2
tar -xjf ~/sync/building/src/pcre-8.39.tar.bz2
tar -xjf ~/sync/building/src/pinentry-0.9.7.tar.bz2
tar -xzf ~/sync/building/src/zlib-1.2.8.tar.gz
tar -xjf ~/sync/building/src/adns-1.4-g10-7.tar.bz2

unzip ~/sync/building/src/sqlite-amalgamation-3140200.zip
cp ~/sync/building/src/libsqlite3.rc ~/sync/building/src/libsqlite3.def sqlite-amalgamation-3140200

#-------------------------------- x86_64-w64-mingw32-pkg-config --------------------------------
mkdir -p ${SYS_ROOT}/bin && cat > ${SYS_ROOT}/bin/${TARGET_TRIPLET}-pkg-config <<EOF
#!/bin/sh
export PKG_CONFIG_LIBDIR=${SYS_ROOT}/lib/pkgconfig
/usr/bin/pkg-config --define-variable=prefix=${SYS_ROOT} \$@
EOF
chmod +x ${SYS_ROOT}/bin/${TARGET_TRIPLET}-pkg-config

# ${SYS_ROOT}/bin/${TARGET_TRIPLET}-pkg-config --list-all

#-------------------------------- sqlite3 --------------------------------
mkdir -p ${SYS_ROOT}/lib/pkgconfig && cat > ${SYS_ROOT}/lib/pkgconfig/sqlite3.pc << EOF
prefix=${SYS_ROOT}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: SQLite
Description: SQL database engine
Version: 3.14.2.0
Libs: -L\${libdir} -lsqlite3
Libs.private:
Cflags: -I\${includedir}
EOF

cd ${SQLITE3_SRC_ROOT}
${TARGET_TRIPLET}-windres -o libsqlite3.rc.o libsqlite3.rc
${TARGET_TRIPLET}-gcc -shared -Wl,--out-implib,libsqlite3.dll.a -O2 -g -o sqlite3.dll libsqlite3.rc.o libsqlite3.def -D_WIN32_WINNT=0x0502 -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_UNLOCK_NOTIFY sqlite3.c

${TARGET_TRIPLET}-strip sqlite3.dll

install -m 0755 -d ${SYS_ROOT}/bin ${SYS_ROOT}/lib ${SYS_ROOT}/include
install -m 0755 -t ${SYS_ROOT}/bin sqlite3.dll
install -m 0644 -t ${SYS_ROOT}/include sqlite3.h sqlite3ext.h
install -m 0644 -T sqlite3.dll ${SYS_ROOT}/lib/libsqlite3.dll.a

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

#-------------------------------- adns --------------------------------
cd ${ADNS_SRC_ROOT} && ${ADNS_SRC_ROOT}/autogen.sh && ${ADNS_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET}

make clean; make -j8; make install

#-------------------------------- gnupg --------------------------------
cd ${GNUPG_SRC_ROOT} && ${GNUPG_SRC_ROOT}/configure --prefix=${SYS_ROOT} \
    --build=${BUILD_TRIPLET} --host=${TARGET_TRIPLET} \
    --disable-card-support --disable-ccid-driver --disable-scdaemon \
    --disable-dns-cert --disable-g13 --disable-gpgtar \
    --with-zlib=${SYS_ROOT} --with-regex=${SYS_ROOT} --with-adns=${SYS_ROOT}

make -j8; make install

# ${TARGET_TRIPLET}-strip ${SYS_ROOT}/bin/*.dll ${SYS_ROOT}/bin/*.exe ${SYS_ROOT}/libexec/*.exe

: '
mkdir -p ${SYS_ROOT}/bin/xxx && cd ${SYS_ROOT}/bin

/bin/cp libadns*.dll libassuan*.dll libgcrypt*.dll libgpg-error*.dll \
    libiconv*.dll libksba*.dll libnpth*.dll zlib*.dll sqlite3.dll \
    adnshost.exe dirmngr*.exe gpg-agent.exe gpg-connect-agent.exe \
    gpg-error.exe gpg2.exe gpgconf.exe gpgsm.exe gpgv2.exe \
    hmac256.exe iconv.exe kbxutil.exe pinentry-w32.exe xxx/

cd ${SYS_ROOT}/bin/xxx
${TARGET_TRIPLET}-strip *.exe *.dll
cp gpg2.exe gpg.exe
cp gpgv2.exe gpgv.exe
mv pinentry-w32.exe pinentry.exe

LC_ALL=C ls -l *.dll
-rwxr-xr-x 1 cauchy cauchy   84992 Jul 15 15:41 libadns6-1.dll
-rwxr-xr-x 1 cauchy cauchy   75776 Jul 15 15:41 libassuan6-0.dll
-rwxr-xr-x 1 cauchy cauchy 1073664 Jul 15 15:41 libgcrypt-20.dll
-rwxr-xr-x 1 cauchy cauchy  104448 Jul 15 15:41 libgpg-error6-0.dll
-rwxr-xr-x 1 cauchy cauchy  943616 Jul 15 15:41 libiconv-2.dll
-rwxr-xr-x 1 cauchy cauchy  206336 Jul 15 15:41 libksba-8.dll
-rwxr-xr-x 1 cauchy cauchy   28672 Jul 15 15:41 libnpth6-0.dll
-rwxr-xr-x 1 cauchy cauchy  114176 Jul 15 15:41 zlib1.dll

LC_ALL=C ls -l *.exe
-rwxr-xr-x 1 cauchy cauchy  38400 Jul 15 15:41 adnshost.exe
-rwxr-xr-x 1 cauchy cauchy  92160 Jul 15 15:41 dirmngr-client.exe
-rwxr-xr-x 1 cauchy cauchy 336896 Jul 15 15:41 dirmngr.exe
-rwxr-xr-x 1 cauchy cauchy 339456 Jul 15 15:41 gpg-agent.exe
-rwxr-xr-x 1 cauchy cauchy 144896 Jul 15 15:41 gpg-connect-agent.exe
-rwxr-xr-x 1 cauchy cauchy  35328 Jul 15 15:41 gpg-error.exe
-rwxr-xr-x 1 cauchy cauchy 902144 Jul 15 15:41 gpg.exe
-rwxr-xr-x 1 cauchy cauchy 902144 Jul 15 15:41 gpg2.exe
-rwxr-xr-x 1 cauchy cauchy 126976 Jul 15 15:41 gpgconf.exe
-rwxr-xr-x 1 cauchy cauchy 436224 Jul 15 15:41 gpgsm.exe
-rwxr-xr-x 1 cauchy cauchy 384512 Jul 15 15:41 gpgv.exe
-rwxr-xr-x 1 cauchy cauchy 384512 Jul 15 15:41 gpgv2.exe
-rwxr-xr-x 1 cauchy cauchy  46592 Jul 15 15:41 hmac256.exe
-rwxr-xr-x 1 cauchy cauchy  43008 Jul 15 15:41 iconv.exe
-rwxr-xr-x 1 cauchy cauchy 142848 Jul 15 15:41 kbxutil.exe
-rwxr-xr-x 1 cauchy cauchy  69632 Jul 15 15:41 pinentry.exe

$ cat > version.txt <<EOF
gnupg-2.1.15

libgcrypt-1.7.3
pinentry-0.9.7

libassuan-2.4.3
libgpg-error-1.24
libiconv-1.14
libksba-1.3.5
npth-1.2
pcre-8.39
zlib-1.2.8
adns-1.4-g10-7
sqlite3-3.14.2
EOF

7z a -t7z -mx9 -ssc -mtc=on -mmt=on -m0=LZMA2 gnupg-2.1.15-w32.7z gnupg-2.1.15-w32/
7z a -t7z -mx9 -ssc -mtc=on -mmt=on -m0=LZMA2 gnupg-2.1.15-w64.7z gnupg-2.1.15-w64/

cd %USERPROFILE%\AppData\Roaming\gnupg
echo Exit Code is %errorlevel%
HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor\Autorun to @chcp 65001>nul

gpg --delete-secret-and-public-keys

$env:Path = "D:\opt\gnupg-2.1.15-w32;" + $env:Path

SET PATH=D:\opt\gnupg-2.1.15-w32

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

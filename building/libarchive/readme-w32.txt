mkdir -p /tmp/w32/include /tmp/w32/lib /tmp/w32/bin
path/to/src/xz/configure --prefix=/tmp/w32 --host=i686-w64-mingw32 --disable-nls
signtool sign /t http://timestamp.verisign.com/scripts/timstamp.dll grep.exe

export PATH=${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/cauchy/gcc-4.7-w32-linux/bin
export W32_ROOT=${HOME}/w32

*) build zlib

vi win32/Makefile.gcc
    PREFIX = i686-w64-mingw32-
    make -f win32/Makefile.gcc
    make test testdll -f win32/Makefile.gcc

install -d ${W32_ROOT}/bin ${W32_ROOT}/lib ${W32_ROOT}/include
install -t ${W32_ROOT}/bin -s   zlib1.dll
install -t ${W32_ROOT}/lib      libz.a libz.dll.a
install -t ${W32_ROOT}/include  zlib.h zconf.h

*) build bzip2
vi libbz2.rc
vi bzip2.rc

i686-w64-mingw32-windres libbz2.rc libbz2.rc.o
i686-w64-mingw32-windres bzip2.rc bzip2.rc.o

i686-w64-mingw32-gcc -O2 -g -c -D_LARGEFILE64_SOURCE=1 -D_FILE_OFFSET_BITS=64 \
    blocksort.c huffman.c crctable.c randtable.c compress.c decompress.c bzlib.c bzip2.c

i686-w64-mingw32-gcc -O2 -g -shared -o bzip2.dll -Wl,--out-implib,libbz2.dll.a libbz2.def libbz2.rc.o \
    blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o

i686-w64-mingw32-ar rcs libbz2.a blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o

i686-w64-mingw32-gcc -O2 -g -o bzip2.exe bzip2.rc.o bzip2.o \
    blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o

install -d ${W32_ROOT}/bin ${W32_ROOT}/lib ${W32_ROOT}/include
install -t ${W32_ROOT}/bin -s   bzip2.exe bzip2.dll
install -t ${W32_ROOT}/lib      libbz2.a libbz2.dll.a
install -t ${W32_ROOT}/include  bzlib.h

*) build gzip2
./configure --host=i686-w64-mingw32 --prefix=${W32_ROOT}

install -d ${W32_ROOT}/bin
install -t ${W32_ROOT}/bin -s   gzip.exe

*) build xz
./configure --host=i686-w64-mingw32 --prefix=${W32_ROOT} --disable-nls

install -d ${W32_ROOT}/bin ${W32_ROOT}/lib ${W32_ROOT}/include/lzma
install -t ${W32_ROOT}/bin -s   src/liblzma/.libs/liblzma-5.dll src/xzdec/xzdec.exe src/xz/xz.exe
install -t ${W32_ROOT}/lib      src/liblzma/.libs/liblzma*.a
install -t ${W32_ROOT}/include  src/liblzma/api/lzma.h src/liblzma/api/lzma/
install -t ${W32_ROOT}/include/lzma  src/liblzma/api/lzma/*.h

*) build libarchive
CPPFLAGS=-I${W32_ROOT}/include LDFLAGS=-L${W32_ROOT}/lib \
./configure --host=i686-w64-mingw32 --prefix=${W32_ROOT} --without-xml2

install -d ${W32_ROOT}/bin
install -t ${W32_ROOT}/bin -s   bsdtar.exe bsdcpio.exe

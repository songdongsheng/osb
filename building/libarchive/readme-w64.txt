mkdir -p /tmp/w64/include /tmp/w64/lib /tmp/w64/bin
path/to/src/xz/configure --prefix=/tmp/w32 --host=x86_64-w64-mingw32 --disable-nls
signtool sign /t http://timestamp.verisign.com/scripts/timstamp.dll grep.exe

export PATH=${HOME}/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/cauchy/gcc-4.7-w64-linux/bin
export W64_ROOT=${HOME}/w64

*) build zlib

vi win32/Makefile.gcc
    PREFIX = x86_64-w64-mingw32-
    make -f win32/Makefile.gcc
    make test testdll -f win32/Makefile.gcc

install -d ${W64_ROOT}/bin ${W64_ROOT}/lib ${W64_ROOT}/include
install -t ${W64_ROOT}/bin -s   zlib1.dll
install -t ${W64_ROOT}/lib      libz.a libz.dll.a
install -t ${W64_ROOT}/include  zlib.h zconf.h

*) build bzip2
vi libbz2.rc
vi bzip2.rc

x86_64-w64-mingw32-windres libbz2.rc libbz2.rc.o
x86_64-w64-mingw32-windres bzip2.rc bzip2.rc.o

x86_64-w64-mingw32-gcc -O2 -g -c -D_LARGEFILE64_SOURCE=1 -D_FILE_OFFSET_BITS=64 \
    blocksort.c huffman.c crctable.c randtable.c compress.c decompress.c bzlib.c bzip2.c

x86_64-w64-mingw32-gcc -O2 -g -shared -o bzip2.dll -Wl,--out-implib,libbz2.dll.a libbz2.def libbz2.rc.o \
    blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o

x86_64-w64-mingw32-ar rcs libbz2.a blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o

x86_64-w64-mingw32-gcc -O2 -g -o bzip2.exe bzip2.rc.o bzip2.o \
    blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o

install -d ${W64_ROOT}/bin ${W64_ROOT}/lib ${W64_ROOT}/include
install -t ${W64_ROOT}/bin -s   bzip2.exe bzip2.dll
install -t ${W64_ROOT}/lib      libbz2.a libbz2.dll.a
install -t ${W64_ROOT}/include  bzlib.h

*) build gzip2
./configure --host=x86_64-w64-mingw32 --prefix=${W64_ROOT}

install -d ${W64_ROOT}/bin
install -t ${W64_ROOT}/bin -s   gzip.exe

*) build xz
./configure --host=x86_64-w64-mingw32 --prefix=${W64_ROOT} --disable-nls

install -d ${W64_ROOT}/bin ${W64_ROOT}/lib ${W64_ROOT}/include/lzma
install -t ${W64_ROOT}/bin -s   src/liblzma/.libs/liblzma-5.dll src/xzdec/xzdec.exe src/xz/xz.exe
install -t ${W64_ROOT}/lib      src/liblzma/.libs/liblzma*.a
install -t ${W64_ROOT}/include  src/liblzma/api/lzma.h src/liblzma/api/lzma/
install -t ${W64_ROOT}/include/lzma  src/liblzma/api/lzma/*.h

*) build libarchive
CPPFLAGS=-I${W64_ROOT}/include LDFLAGS=-L${W64_ROOT}/lib \
./configure --host=x86_64-w64-mingw32 --prefix=${W64_ROOT} --without-xml2

install -d ${W64_ROOT}/bin
install -t ${W64_ROOT}/bin -s   bsdtar.exe bsdcpio.exe

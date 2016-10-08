------------------------------------------------------------------------
SET OPENSSL_CONF=C:\var\pool\openssl\ssl\openssl.cnf

Patch (apps\openssl.c)
======================
BIO_printf(bio_err, "WARNING: can't open config file: %s\n", p);

------------------------------------------------------------------------
perl Configure ^
    no-zlib enable-camellia ^
    --prefix=D:/var/tmp/openssl-win32 ^
    VC-WIN32

ms\do_nasm

SET CFLAG=/nologo /W3 /MD /EHsc /O2 /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.2 /VERSION:1.2
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.2 /VERSION:1.2 /DLL

/Fd"D:\var\tmp\openssl-win32\openssl-app.pdb"
/Fd"D:\var\tmp\openssl-win32\openssl-lib.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install

nmake -f ms\nt.mak
nmake -f ms\nt.mak test
nmake -f ms\nt.mak install

------------------------------------Win64/x64------------------------------------
perl Configure ^
    no-zlib enable-camellia ^
    --prefix=D:/var/tmp/openssl-win64 ^
    VC-WIN64A

ms\do_win64a

SET CFLAG=/nologo /W3 /MD /EHsc /O2 /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X64 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.2 /VERSION:1.2
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X64 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.2 /VERSION:1.2 /DLL

/Fd"D:\var\tmp\openssl-win64\openssl-app.pdb"
/Fd"D:\var\tmp\openssl-win64\openssl-lib.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install

nmake -f ms\nt.mak
nmake -f ms\nt.mak test
nmake -f ms\nt.mak install

-------------------------------- Compile for Windows on Linux --------------------------------
shared/no-shared

export CROSS_COMPILE=i686-w64-mingw32-
./Configure no-zlib enable-camellia --prefix=/tmp/win32 --cross-compile-prefix=i686-w64-mingw32- mingw
make clean; make -j8

export CROSS_COMPILE=x86_64-w64-mingw32-
./Configure no-zlib enable-camellia --prefix=/tmp/win64 --cross-compile-prefix=x86_64-w64-mingw32- mingw64
make clean; make -j8

#define IN6_ARE_ADDR_EQUAL(a, b) \
    (((const uint32_t *)(a))[0] == ((const uint32_t *)(b))[0] \
    && ((const uint32_t *)(a))[1] == ((const uint32_t *)(b))[1] \
    && ((const uint32_t *)(a))[2] == ((const uint32_t *)(b))[2] \
    && ((const uint32_t *)(a))[3] == ((const uint32_t *)(b))[3])

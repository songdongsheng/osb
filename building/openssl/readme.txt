------------------------------------------------------------------------
SET OPENSSL_CONF=C:\var\pool\openssl\ssl\openssl.cnf


Patch (apps\openssl.c)
======================
BIO_printf(bio_err, "WARNING: can't open config file: %s\n",p);


------------------------------------------------------------------------
$(LIB_D)\openssl.dll: $(CRYPTOOBJ) $(SSLOBJ)
	$(LINK) $(MLFLAGS) /out:$(LIB_D)\openssl.dll /PDB:$(LIB_D)\openssl.pdb /def:ms/openssl.def @<<
  $(SHLIB_EX_OBJ) $(CRYPTOOBJ)  $(SSLOBJ) zlib.lib $(EX_LIBS)
<<
	IF EXIST $@.manifest mt -nologo -manifest $@.manifest -outputresource:$@;2

$(ENG_D)\gost.dll: $(GOSTOBJ)

nmake -f ms\ntdll.mak out32dll\openssl.dll


------------------------------------------------------------------------
http://wagner.pp.ru/~vitus/articles/openssl-mingw.html
perl Configure enable-mdc2 enable-zlib enable-camellia mingw
make CC=i686-w64-mingw32-gcc RANLIB=i686-w64-mingw32-ranlib


------------------------------------------------------------------------
perl Configure enable-zlib VC-WIN32 ^
    --prefix=E:/var/pool/openssl-win32 ^
    -I"E:\var\vcs\git\osb\windows-x86-msvcr110\include" ^
    -L"E:\var\vcs\git\osb\windows-x86-msvcr110\lib"

ms\do_nasm

SET CFLAG=/nologo /W3 /MD /EHsc /O2 /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.1 /VERSION:1.2
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.1 /VERSION:1.2 /DLL

/Fd"E:\var\pool\openssl-win32\openssl-app.pdb"
/Fd"E:\var\pool\openssl-win32\openssl-lib.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install


------------------------------------Win64/x64------------------------------------
perl Configure enable-zlib VC-WIN64A ^
    --prefix=E:/var/pool/openssl-win64 ^
    -I"E:\var\vcs\git\osb\windows-x64-msvcr110\include" ^
    -L"E:\var\vcs\git\osb\windows-x64-msvcr110\lib"

ms\do_win64a

SET CFLAG=/nologo /W3 /MD /EHsc /O2 /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X64 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.2 /VERSION:1.2
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X64 /DEBUG /RELEASE /SUBSYSTEM:CONSOLE,5.2 /VERSION:1.2 /DLL

/Fd"E:\var\pool\openssl-win64\openssl-app.pdb"
/Fd"E:\var\pool\openssl-win64\openssl-lib.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install


-------------------------------- mingw-w64 --------------------------------
--with-zlib-lib=/home/cauchy/w32/lib --with-zlib-include=/home/cauchy/w32/include

./Configure shared zlib --prefix=/home/cauchy/w32 --cross-compile-prefix=i686-w64-mingw32- mingw

./Configure shared zlib --prefix=/home/cauchy/w64 --cross-compile-prefix=x86_64-w64-mingw32- mingw64

LDFLAGS=-L/home/cauchy/w32/lib CPPFLAGS=-I/home/cauchy/w32/include

#define IN6_ARE_ADDR_EQUAL(a, b) \
    (((const uint32_t *)(a))[0] == ((const uint32_t *)(b))[0] \
    && ((const uint32_t *)(a))[1] == ((const uint32_t *)(b))[1] \
    && ((const uint32_t *)(a))[2] == ((const uint32_t *)(b))[2] \
    && ((const uint32_t *)(a))[3] == ((const uint32_t *)(b))[3])

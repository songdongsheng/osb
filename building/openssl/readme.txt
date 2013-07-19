------------------------------------------------------------------------
SET OPENSSL_CONF=C:\var\pool\openssl\ssl\openssl.cnf

Patch (apps\openssl.c)
======================
BIO_printf(bio_err, "WARNING: can't open config file: %s\n",p);


------------------------------------------------------------------------
http://wagner.pp.ru/~vitus/articles/openssl-mingw.html
perl Configure enable-mdc2 enable-zlib enable-camellia mingw
make CC=i686-w64-mingw32-gcc RANLIB=i686-w64-mingw32-ranlib


------------------------------------------------------------------------
perl Configure enable-zlib VC-WIN32 ^
    --prefix=C:/var/pool/openssl-win32 ^
    -I"C:\var\vcs\git\osb\windows-x86-msvcr110\include" ^
    -L"C:\var\vcs\git\osb\windows-x86-msvcr110\lib"

ms\do_nasm

SET CFLAG=/nologo /W3 /MD /EHsc /O2 /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /RELEASE /SUBSYSTEM:CONSOLE
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /RELEASE /SUBSYSTEM:CONSOLE /DLL

/Fd"C:\var\pool\openssl-win32\openssl.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install


------------------------------------Win64/x64------------------------------------
perl Configure enable-zlib VC-WIN64A ^
    --prefix=C:/var/pool/openssl-win64 ^
    -I"C:\var\vcs\git\osb\windows-x64-msvcr110\include" ^
    -L"C:\var\vcs\git\osb\windows-x64-msvcr110\lib"

ms\do_win64a

SET CFLAG=/nologo /W3 /MD /EHsc /O2 /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X64 /RELEASE /SUBSYSTEM:CONSOLE
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X64 /RELEASE /SUBSYSTEM:CONSOLE /DLL

/Fd"C:\var\pool\openssl-win64\openssl.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install

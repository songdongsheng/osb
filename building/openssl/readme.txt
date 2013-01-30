------------------------------------------------------------------------
http://wagner.pp.ru/~vitus/articles/openssl-mingw.html
perl Configure enable-mdc2 enable-zlib enable-camellia mingw
make CC=i686-w64-mingw32-gcc RANLIB=i686-w64-mingw32-ranlib

perl Configure enable-mdc2 enable-zlib enable-camellia VC-WIN32 ^
    --prefix=C:/var/pool/openssl ^
    -I"E:\setup\SkyDrive\vcs\git\osb\windows-x86-msvcr100\include" ^
    -L"E:\setup\SkyDrive\vcs\git\osb\windows-x86-msvcr100\lib"

ms\do_nasm

SET CFLAG=/nologo /W3 /MD /EHsc /arch:SSE2 /O2 /Oy- /Zi ^
    /D"_WIN32_WINNT=0x0502" /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS
SET  LFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /RELEASE /SUBSYSTEM:CONSOLE
SET MLFLAGS=/NOLOGO /OPT:ICF,REF /MACHINE:X86 /RELEASE /SUBSYSTEM:CONSOLE /DLL

/Fd"C:\var\pool\openssl.pdb"

nmake -f ms\ntdll.mak
nmake -f ms\ntdll.mak test
nmake -f ms\ntdll.mak install

SET OPENSSL_CONF=C:\var\pool\openssl\ssl\openssl.cnf


Patch (apps\openssl.c)
======================
set OPENSSL_CONF=C:\var\pool\openssl\ssl\openssl.cnf

    char pname[PROG_NAME_SIZE+1], cname[512];

    p=getenv("OPENSSL_CONF");
    if (p == NULL)
        p=getenv("SSLEAY_CONF");

    if (p == NULL) {
        FILE *fp;
        p=to_free=make_config_name();
        fp = fopen(p, "rb");
        if (fp == NULL) {
            GetModuleFileNameA(NULL, cname, sizeof(cname));
            *(strrchr(cname, '\\') + 1) = '\0';
            strcat(cname, "..\\ssl\\openssl.cnf");
            p = cname;
        } else {
            fclose(fp);
        }
    }
------------------------------------------------------------------------

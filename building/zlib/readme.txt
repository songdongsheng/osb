MSBuild zlib.vcxproj /t:Rebuild /p:PlatformToolset=v110;Configuration=Release;Platform=Win32
MSBuild zlib.vcxproj /t:Rebuild /p:PlatformToolset=v110;Configuration=Release;Platform=x64

Open zlib\win32\Makefile.msc replace line 31 with
    ASFLAGS = -coff -Zi -safeseh $(LOC)

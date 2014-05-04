#!/bin/sh

find /home/cauchy/sync/building/project/00_compiler -type f -name "*.sh" | xargs chmod 0755

/home/cauchy/sync/building/project/00_compiler/gcc-4.7/cross-win32.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.7/cross-win64.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.7/cross-native-win32.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.7/cross-native-win64.sh

/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-win32-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-win64-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-native-win32-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-native-win64-thin.sh

#/bin/cp ${HOME}/native/gcc-4.8-win32/bin/*.dll ${HOME}/sync/building/binary/windows-x86-gcc-4.8/bin/
#/bin/cp ${HOME}/native/gcc-4.8-win64/bin/*.dll ${HOME}/sync/building/binary/windows-x64-gcc-4.8/bin/

/home/cauchy/sync/building/project/00_compiler/gcc-4.9/cross-win32-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.9/cross-win64-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.9/cross-native-win32-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.9/cross-native-win64-thin.sh

/home/cauchy/sync/building/project/00_compiler/gcc-4.10/cross-win32-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.10/cross-win64-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.10/cross-native-win32-thin.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.10/cross-native-win64-thin.sh

/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-arm64.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-armhf.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-powerpc64.sh
/home/cauchy/sync/building/project/00_compiler/gcc-4.8/cross-sparc64.sh

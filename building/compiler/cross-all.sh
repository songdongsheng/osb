#!/bin/bash

cd /home/cauchy/vcs/svn && svn up gcc

cd /home/cauchy/vcs/git/mingw-w64-v3.x && git pull -v
cd /home/cauchy/vcs/git/mingw-w64-master && git pull -v

find /home/cauchy/daily/ -type f -name "*.sh" | xargs chmod 0755

/home/cauchy/daily/gcc-4.8/cross-win32-thin.sh
/home/cauchy/daily/gcc-4.8/cross-win64-thin.sh
/home/cauchy/daily/gcc-4.8/cross-native-win32-thin.sh
/home/cauchy/daily/gcc-4.8/cross-native-win64-thin.sh

#/bin/cp ${HOME}/native/gcc-4.8-win32/bin/*.dll ${HOME}/sync/building/binary/windows-x86-gcc-4.8/bin/
#/bin/cp ${HOME}/native/gcc-4.8-win64/bin/*.dll ${HOME}/sync/building/binary/windows-x64-gcc-4.8/bin/

/home/cauchy/daily/gcc-4.9/cross-win32-thin.sh
/home/cauchy/daily/gcc-4.9/cross-win64-thin.sh
/home/cauchy/daily/gcc-4.9/cross-native-win32-thin.sh
/home/cauchy/daily/gcc-4.9/cross-native-win64-thin.sh

/home/cauchy/daily/gcc-5.0/cross-win32-thin.sh
/home/cauchy/daily/gcc-5.0/cross-win64-thin.sh
/home/cauchy/daily/gcc-5.0/cross-native-win32-thin.sh
/home/cauchy/daily/gcc-5.0/cross-native-win64-thin.sh

/home/cauchy/daily/gcc-4.8/cross-arm64.sh
/home/cauchy/daily/gcc-4.8/cross-armhf.sh
/home/cauchy/daily/gcc-4.8/cross-powerpc64.sh
/home/cauchy/daily/gcc-4.8/cross-sparc64.sh

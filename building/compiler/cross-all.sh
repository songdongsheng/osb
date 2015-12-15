#!/bin/bash

export HOME=/home/cauchy

find ${HOME}/daily/ -type f -name "*.sh" | xargs chmod 0755

cd ${HOME}/vcs/svn && svn up gcc

cd ${HOME}/vcs/git/mingw-w64-v4.x && git pull -v
cd ${HOME}/vcs/git/mingw-w64-master && git pull -v

cat ${HOME}/vcs/svn/gcc/branches/gcc-4_9-branch/gcc/BASE-VER
cat ${HOME}/vcs/svn/gcc/branches/gcc-5-branch/gcc/BASE-VER
cat ${HOME}/vcs/svn/gcc/trunk/gcc/BASE-VER

cat ${HOME}/vcs/svn/gcc/branches/gcc-4_9-branch/gcc/DATESTAMP
cat ${HOME}/vcs/svn/gcc/branches/gcc-5-branch/gcc/DATESTAMP
cat ${HOME}/vcs/svn/gcc/trunk/gcc/DATESTAMP

${HOME}/daily/gcc-4.9/cross-win32-thin.sh
${HOME}/daily/gcc-4.9/cross-win64-thin.sh
${HOME}/daily/gcc-4.9/cross-native-win32-thin.sh
${HOME}/daily/gcc-4.9/cross-native-win64-thin.sh

${HOME}/daily/gcc-5.x/cross-win32-thin.sh
${HOME}/daily/gcc-5.x/cross-win64-thin.sh
${HOME}/daily/gcc-5.x/cross-native-win32-thin.sh
${HOME}/daily/gcc-5.x/cross-native-win64-thin.sh

${HOME}/daily/gcc-6.x/cross-win32-thin.sh
${HOME}/daily/gcc-6.x/cross-win64-thin.sh
${HOME}/daily/gcc-6.x/cross-native-win32-thin.sh
${HOME}/daily/gcc-6.x/cross-native-win64-thin.sh

${HOME}/native/ssh-rsa-2048.rsync &

#exit 0

${HOME}/daily/glibc-2.22/cross-arm64.sh
${HOME}/daily/glibc-2.22/cross-armhf.sh
${HOME}/daily/glibc-2.22/cross-powerpc64.sh
${HOME}/daily/glibc-2.22/cross-s390x.sh
${HOME}/daily/glibc-2.22/cross-sparc64.sh

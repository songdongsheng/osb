#!/bin/bash
# https://ftp.gnu.org/gnu/make/?C=M;O=D

export HOME=/home/cauchy

find ${HOME}/daily/ -type f -name "*.sh" | xargs chmod 0755

cd ${HOME}/vcs/svn && svn up gcc

cd ${HOME}/vcs/git/mingw-w64-v5.x && git pull -v
cd ${HOME}/vcs/git/mingw-w64-master && git pull -v

cat ${HOME}/vcs/svn/gcc/branches/gcc-5-branch/gcc/BASE-VER
cat ${HOME}/vcs/svn/gcc/branches/gcc-6-branch/gcc/BASE-VER
cat ${HOME}/vcs/svn/gcc/trunk/gcc/BASE-VER

cat ${HOME}/vcs/svn/gcc/branches/gcc-5-branch/gcc/DATESTAMP
cat ${HOME}/vcs/svn/gcc/branches/gcc-6-branch/gcc/DATESTAMP
cat ${HOME}/vcs/svn/gcc/trunk/gcc/DATESTAMP

${HOME}/daily/gcc-5.x/cross-win32-thin.sh
${HOME}/daily/gcc-5.x/cross-win64-thin.sh
${HOME}/daily/gcc-5.x/cross-native-win32-thin.sh
${HOME}/daily/gcc-5.x/cross-native-win64-thin.sh

${HOME}/daily/gcc-6.x/cross-win32-thin.sh
${HOME}/daily/gcc-6.x/cross-win64-thin.sh
${HOME}/daily/gcc-6.x/cross-native-win32-thin.sh
${HOME}/daily/gcc-6.x/cross-native-win64-thin.sh

${HOME}/daily/gcc-7.x/cross-win32-thin.sh
${HOME}/daily/gcc-7.x/cross-win64-thin.sh
${HOME}/daily/gcc-7.x/cross-native-win32-thin.sh
${HOME}/daily/gcc-7.x/cross-native-win64-thin.sh

#exit 0

#${HOME}/native/ssh-rsa-2048.rsync &

export GLIBC_SRC_ROOT=${HOME}/src/glibc-2.24
export GLIBC_PATCH=${HOME}/daily/glibc-2.24/glibc.patch
export GLIBC_GIT_DIR=${HOME}/vcs/git/glibc/.git

for arch in sparc64 arm64 armhf powerpc64 s390x; do
echo ${arch}
    cd ${GLIBC_SRC_ROOT}
    GIT_DIR=${GLIBC_GIT_DIR} git checkout -f 2.24.x
    GIT_DIR=${GLIBC_GIT_DIR} git clean -dfx
    patch -s -p1 < ${GLIBC_PATCH}
    ${HOME}/daily/glibc-2.24/cross-${arch}.sh
done

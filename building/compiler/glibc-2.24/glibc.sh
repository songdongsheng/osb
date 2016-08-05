#!/bin/sh

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

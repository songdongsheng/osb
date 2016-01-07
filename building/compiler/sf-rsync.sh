#!/usr/bin/env bash

#
# https://sourceforge.net/p/forge/documentation/Release Files for Download/
#

# ssh -t dongsheng,osb@shell.sourceforge.net create
# ssh -t dongsheng,mingw-w64@shell.sourceforge.net create

cd /home/cauchy/native

SSH_AUTH_SOCK=/tmp/ssh-6BcDSTKZu9Nk/agent.16804; export SSH_AUTH_SOCK;
SSH_AGENT_PID=16805; export SSH_AGENT_PID;

# rsync -tsz -e ssh README-w64.rst  dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/README.rst
# rsync -tsz -e ssh README-w64.rst  dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/README.rst

rsync -tsz -e ssh README.rst    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/

rsync -tsz --progress -e ssh gcc-4.9-win32_4.9.4-20160106.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/4.9/x86/testing/
rsync -tsz --progress -e ssh gcc-4.9-win64_4.9.4-20160106.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/4.9/x64/testing/

rsync -tsz --progress -e ssh gcc-4.9-win32_4.9.4-20160106.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/4.9/
rsync -tsz --progress -e ssh gcc-4.9-win64_4.9.4-20160106.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/4.9/

rsync -tsz --progress -e ssh gcc-5-win32_5.3.1-20160106.7z      dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/5.x/x86/testing/
rsync -tsz --progress -e ssh gcc-5-win64_5.3.1-20160106.7z      dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/5.x/x64/testing/

rsync -tsz --progress -e ssh gcc-5-win32_5.3.1-20160106.7z      dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/5.x/
rsync -tsz --progress -e ssh gcc-5-win64_5.3.1-20160106.7z      dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/5.x/

rsync -tsz --progress -e ssh gcc-6-win32_6.0.0-20160106.7z      dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/6.x/x86/testing/
rsync -tsz --progress -e ssh gcc-6-win64_6.0.0-20160106.7z      dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/6.x/x64/testing/

rsync -tsz --progress -e ssh gcc-6-win32_6.0.0-20160106.7z      dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/6.x/
rsync -tsz --progress -e ssh gcc-6-win64_6.0.0-20160106.7z      dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/6.x/

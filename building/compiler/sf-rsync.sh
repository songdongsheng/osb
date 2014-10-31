#!/usr/bin/env bash

SSH_AUTH_SOCK=/tmp/ssh-SkThUdoVJVzK/agent.3792; export SSH_AUTH_SOCK;
SSH_AGENT_PID=3793; export SSH_AGENT_PID;

#
# https://sourceforge.net/p/forge/documentation/Release Files for Download/
#

# ssh -t dongsheng,osb@shell.sourceforge.net create
# ssh -t dongsheng,mingw-w64@shell.sourceforge.net create

rsync -tsz --progress -e ssh gcc-5.0-win32_5.0.0-20141030.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/5.0/x86/testing/
rsync -tsz --progress -e ssh gcc-5.0-win64_5.0.0-20141030.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/5.0/x64/testing/

rsync -tsz --progress -e ssh gcc-5.0-win32_5.0.0-20141030.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/5.0/
rsync -tsz --progress -e ssh gcc-5.0-win64_5.0.0-20141030.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/5.0/

rsync -tsz --progress -e ssh gcc-4.8-win32_4.8.4-20141030.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/4.8/x86/testing/
rsync -tsz --progress -e ssh gcc-4.8-win64_4.8.4-20141030.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/4.8/x64/testing/

rsync -tsz --progress -e ssh gcc-4.8-win32_4.8.4-20141030.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/4.8/
rsync -tsz --progress -e ssh gcc-4.8-win64_4.8.4-20141030.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/4.8/

rsync -tsz -e ssh README.rst                                    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/

rsync -tsz --progress -e ssh gcc-4.9-win32_4.9.3-20141030.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/4.9/x86/testing/
rsync -tsz --progress -e ssh gcc-4.9-win64_4.9.3-20141030.7z    dongsheng,osb@frs.sourceforge.net:/home/frs/project/osb/gcc/4.9/x64/testing/

rsync -tsz --progress -e ssh gcc-4.9-win32_4.9.3-20141030.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win32/Personal Builds'/dongsheng-daily/4.9/
rsync -tsz --progress -e ssh gcc-4.9-win64_4.9.3-20141030.7z    dongsheng,mingw-w64@frs.sourceforge.net:/home/frs/project/mingw-w64/'Toolchains targetting Win64/Personal Builds'/dongsheng-daily/4.9/

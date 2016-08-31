#!/bin/sh

SSH_AUTH_SOCK=/tmp/ssh-SRr7zwHrgk9c/agent.7364; export SSH_AUTH_SOCK;
SSH_AGENT_PID=7365; export SSH_AGENT_PID;

for i in ${HOME}/vcs/hg/jdk8u ${HOME}/vcs/hg/jdk9; do
  [ -f $i/get_source.sh ] || continue;
  (cd $i ; echo $i; bash get_source.sh; echo)
done

for i in ${HOME}/vcs/hg/*; do
  [ -d $i/.hg/ ] || continue;
  (cd $i ; echo $i; hg -v pull -u; echo)
done

for i in ${HOME}/vcs/cvs/*; do
  [ -d $i/CVS/ ] || continue;
  ( cd $i ; echo $i; cvs -q up -dPA; echo)
done

for i in ${HOME}/vcs/netbsd/*; do
  [ -d $i/CVS/ ] || continue;
  ( cd $i ; echo $i; cvs -q up -dPA; echo)
done

for i in ${HOME}/vcs/git/*; do
  [ -d $i/.git/ ] || continue;
  ( cd $i ; echo $i; git pull; echo)
done

if [ -d ${HOME}/vcs/git/linux/.git/ ]; then
  ( cd ${HOME}/vcs/git/linux;
    git pull
   #git pull git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master:master

    git fetch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git \
        linux-4.6.y:linux-4.6.y \
        linux-4.4.y:linux-4.4.y
  )
fi

for i in ${HOME}/vcs/svn/*; do
  [ -d $i/.svn/ ] || continue;
  ( cd $i ; echo $i; svn up; echo)
done

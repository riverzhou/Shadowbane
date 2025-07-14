# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbbuild.sh
# Purpose:   Pulls a branch from the repo and compiles.
#            If no branch named it builds master

#!/bin/zsh

cd build/Server
#git remote update

#if [ "$1" == "" ]
# then
#  git checkout  master
#  git pull
# else
#  git checkout $1
#  git pull
#fi

cd ../..
ant -buildfile build/build.xml

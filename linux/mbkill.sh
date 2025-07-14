#!/bin/bash

# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbkill.sh
# Purpose:   Script will terminate a running game instance

gmloginrunning=$(ps --pid `cat logs/gmlogin.pid` -o comm=)

if [ $gmloginrunning ]
	then
gmloginpid=$(cat logs/gmlogin.pid)
kill -9 $gmloginpid
fi

loginrunning=$(ps --pid `cat logs/login.pid` -o comm=)

if [ $loginrunning ]
	then
loginpid=$(cat logs/login.pid)
kill -9 $loginpid
fi

gamerunning=$(ps --pid `cat logs/world.pid` -o comm=)

if [ $gamerunning ]
        then
gamepid=$(cat logs/world.pid)
kill -9 $gamepid
fi

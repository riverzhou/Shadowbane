#!/bin/bash

LIB=build/bin/magicbane.jar

search=$(ps --pid `cat logs/gmlogin.pid` -o comm=)

if [ $search ]
        then
                echo "Exit - gmlogin server is already running"
		exit 1
        else
                echo $$ > logs/gmlogin.pid
fi

# Check that configuration is present

if [ -z "$MB_WORLD_NAME" ]; then
    
CONFIGFILE="mb.conf/magicbane.conf"

echo Configure using $CONFIGFILE

set -a
. $CONFIGFILE
set +a
    
fi

CLASSPATH=Dependencies/*

if [ "$1" == "-debug" ]
	then

        exec java -server -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5000,server=y -cp "$CLASSPATH":"$LIB" engine.server.login.LoginServer
	else
	exec java -server -Xcomp -XX:ReservedCodeCacheSize=2048m -cp "$CLASSPATH":"$LIB" engine.server.login.GmLoginServer -Djava.awt.headless=true
fi

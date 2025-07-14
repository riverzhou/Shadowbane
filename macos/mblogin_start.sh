#!/bin/zsh

LIB=build/bin/magicbane.jar

search=$(ps -p `cat logs/login.pid` -o comm=)

if [ $search ]
        then
                echo "Exit - login server is already running"
                exit 1
        else
                echo $$ > logs/login.pid
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

exec java -server -Xcomp -XX:ReservedCodeCacheSize=2048m -cp "$CLASSPATH":"$LIB" engine.server.login.LoginServer -Djava.awt.headless=true


#!/bin/zsh

search=$(ps -p `cat logs/world.pid` -o comm=)

LIB=build/bin/magicbane.jar

if [ $search ]
        then
                echo "Exit - server is already running"
                exit 1
        else
                echo $$ > logs/world.pid
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

exec java -server -Xcomp -XX:ReservedCodeCacheSize=2048m -cp "$CLASSPATH":"$LIB" engine.server.world.WorldServer -Djava.awt.headless=true


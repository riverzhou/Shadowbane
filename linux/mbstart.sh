#!/bin/bash -e

# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbstart.sh
# Purpose:   Main entrypoint to spin up a cold game.

cat /dev/null > console_gmlogin
cat /dev/null > console_login
cat /dev/null > console_server

# Load in config data for MagicBane
# If no config located in the mount directory
# then we will use a default bootable config
# from mb.data

CONFIGFILE="mb.conf/magicbane.conf"

echo Configure using $CONFIGFILE

set -a
. $CONFIGFILE
set +a

# The local address used by Bind can differ from
# the public facing IP for a number of reasons.
# In the case of MagicBox; a network bridge.

if [ $MB_BIND_ADDR == "0.0.0.0" ]; then
export MB_BIND_ADDR=$(hostname -I | grep -o "^[0-9.]*")
fi

# Touch population file if it does not yet exist

if [ ! -f mb.data/$MB_WORLD_NAME.pop ]; then
    echo "mb.data/$MB_WORLD_NAME.pop"
    echo 0 > mb.data/$MB_WORLD_NAME.pop
fi

echo starting servers

./mbgmlogin_start.sh &>> console_gmlogin &
./mblogin_start.sh &>> console_login &
./mbserver_start.sh $1 &>> console_server &
exit 0


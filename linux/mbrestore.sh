#!/bin/bash

# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbrestore.sh
# Purpose:   Used to restore magicbane from a backup. If
#            no name is given dumps/mbdump.sql is assumed.

echo Killing server

./mbkill.sh

if [ "$1" == "" ]
        then
         INPUTFILE="mbdump.sql"
        else
         INPUTFILE="$1"
fi

# Strip DEFINER tags from the input

        sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i  dumps/$INPUTFILE
        echo "Restoring database from dumps/$INPUTFILE"

# Restore the database

        mysql -uroot -p12345678 magicbane < dumps/$INPUTFILE
        echo "Done!"

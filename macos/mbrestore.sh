#!/bin/zsh

# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbrestore.sh
# Purpose:   Used to restore magicbane from a backup. If
#            no name is given dumps/mbdump.sql is assumed.

echo Killing server

./mbkill.sh

INPUTFILE="mbdump.sql"

# Strip DEFINER tags from the input

#        sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i  dumps/$INPUTFILE
#        echo "Restoring database from dumps/$INPUTFILE"

# Restore the database

        mysql -uroot -p12345678 magicbane < dumps/$INPUTFILE
        echo "Done!"

# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbdump.sh
# Purpose:   Create a backup of the Magicbane database.

#!/bin/bash

echo Killing Server

./mbkill.sh

if [ "$1" == "" ]
      then
       OUTFILE="mbdump.sql"
      else
       OUTFILE="$1"
fi

        echo "Dumping database to dumps/$OUTFILE"

# Dump database to target file

        mysqldump --routines=true magicbane > dumps/$OUTFILE

# Strip DEFINER tags from output file

        sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i  dumps/$OUTFILE
        echo "Done!"

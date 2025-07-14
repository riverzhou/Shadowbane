# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbdump.sh
# Purpose:   Create a backup of the Magicbane database.

#!/bin/zsh

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

        /usr/local/mysql/bin/mysqldump -uroot -p12345678 --routines=true magicbane > dumps/$OUTFILE

# Strip DEFINER tags from output file

        #sed -i 's/\sDEFINER=`[^`]*`@`[^`]*`//g' dumps/$OUTFILE
        echo "Done!"

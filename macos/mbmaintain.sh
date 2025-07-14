#!/bin/zsh

. /Users/river/.zshrc
cd /Users/river/magicbane

./mbdump.sh >> /Users/river/magicbane/mbmaintain.log 2>&1
cp dumps/mbdump.sql dumps/mbdump.`date +%Y%m%d-%H:%M:%S`.sql

sleep 3

./mb.data/updatebank.sh >> /Users/river/magicbane/mbmaintain.log 2>&1

./mbstart.sh >> /Users/river/magicbane/mbmaintain.log 2>&1


#!/bin/bash

cd /home/river/magicbane

./mbdump.sh >> mbmaintain.log 2>&1
cp dumps/mbdump.sql dumps/mbdump.`date +%Y%m%d-%H:%M:%S`.sql

sleep 3

./mb.data/updatebank.sh >> mbmaintain.log 2>&1

./mbstart.sh >> mbmaintain.log 2>&1

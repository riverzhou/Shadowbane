#!/bin/bash -e

# MagicBox : © 2022 Magicbane Project (www.magicbane.com)
# File:      mbrestart.sh
# Purpose:   By convention the main startup script for MagicBane.

./mbkill.sh
sleep 3
./mbstart.sh $1


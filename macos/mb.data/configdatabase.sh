#!/bin/zsh

#service  mysql start

mysql -uroot -p12345678 -e "SET GLOBAL log_bin_trust_function_creators = 1;"
mysql -uroot -p12345678 -e "CREATE USER 'magicbox'@'localhost' IDENTIFIED BY 'ArtyomWasHere';"
mysql -uroot -p12345678 -e "CREATE DATABASE magicbane CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -uroot -p12345678 -e "GRANT ALL PRIVILEGES ON *.* TO 'magicbox'@'localhost';"
mysql -uroot -p12345678 -e "FLUSH PRIVILEGES;"
mysql -uroot -p12345678 -e "SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));"

mysql -u root -p12345678 magicbane < /Users/river/magicbane/mb.data/magicbane.sql


#!/bin/bash

allpackage=$(apt list --installed | sed "s/\/.*//g")

for a in $(cat package.conf)
do
    if [ "$(echo "$allpackage" | grep -P "^$a\$")" == "" ]
    then
        apt-get install -y $a > /dev/null 
    fi
done

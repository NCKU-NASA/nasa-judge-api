#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi


for a in $(seq 1 1 4)
do
    if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 brctl show LAN | grep lan${a}:)" == "" ]
    then
        echo false
        exit 0
    fi
done


echo true


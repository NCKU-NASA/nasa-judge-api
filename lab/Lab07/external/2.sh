#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

for a in $(seq 1 1 2)
do
    if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ip a 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep lan${a}: | grep "master LAN")" == "" ]
    then
        echo false
        exit 0
    fi
done


echo true

#set +e

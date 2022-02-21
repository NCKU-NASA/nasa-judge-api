#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <clt ip>"
    exit 0
fi

if [ "$(sshpass -p finalexam ssh WEB$(printf "%02d" $(shuf -i 1-50 -n 1))@$1 whoami)" != "" ]
then
    echo false
    exit 0
fi
echo true


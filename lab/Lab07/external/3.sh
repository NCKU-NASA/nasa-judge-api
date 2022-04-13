#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ip a 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep inet | grep LAN | grep 192.168.3.254/24)" == "" ]
then
    echo false
    exit 0
fi

echo true

#set +e

#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId> <clt_ip>"
    exit 0
fi

#set -e

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(ssh $username@$1 ssh $username@$3 curl --connect-timeout 1 -s -w "%{http_code}" -o /dev/null www.$username.nasa)" == "" ]
then
    echo false
    exit 0
fi


echo true

#set +e

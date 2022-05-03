#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

username=$(echo "$2" | awk '{print tolower($0)}')

dead=false

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 curl --connect-timeout 1 -L -k 10.31.31.1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "$1" ]
then
    echo false
    dead=true
fi


if $dead
then
    exit 0
fi

echo true

#set +e

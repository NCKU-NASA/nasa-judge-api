#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId> <clt_ip>"
    exit 0
fi

#set -e

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(ssh $username@$1 ssh $username@$3 dig www.$username.nasa +time=1 +tries=1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "www\.$username\.nasa\..*IN.*A\s*192\.168\.3\.1")" == "" ]
then
    echo false
    exit 0
fi


echo true

#set +e

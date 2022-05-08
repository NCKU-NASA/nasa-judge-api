#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <studentId>"
    exit 0
fi

#set -e

if [ "$(curl --connect-timeout 1 -s -w "%{http_code}" -o /dev/null www.$1.nasa 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "200" ]
then
    echo false
    exit 0
fi
echo true

#set +e


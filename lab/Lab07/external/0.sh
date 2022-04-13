#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 hostname)" != "switch" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ping switch -c 1 -W 1 | grep "bytes from switch (.*): icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi

echo true

#set +e

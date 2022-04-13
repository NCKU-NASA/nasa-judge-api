#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t frontend env | grep HOSTIP | sed "s/[^0-9.]*//g")" != "$1" ]
then
    echo false
    exit 0
fi

echo true

#set -e

exit 0

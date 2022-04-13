#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 file /opt/pi | grep ELF)" == "" ]
then
    echo false
    exit 0
fi

echo true

#set +e

exit 0

#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 df -h | grep "mnt\|md0" | awk '{print $2}')" != "20G" ]
then
    echo false
    exit 0
fi

echo true
exit 0

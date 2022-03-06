#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ls -l /dev/md0 | awk '{print substr($1,1,1) $4}')" != "bdisk" ]
then
    echo false
    exit 0
fi


echo true
exit 0
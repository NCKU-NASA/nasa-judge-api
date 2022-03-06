#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 lsblk | grep md0 | awk '($6 == "raid0") {count++} END {print count}')" != "2" ]
then
    echo false
    exit 0
fi


echo true
exit 0
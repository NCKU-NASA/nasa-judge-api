#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

diskcont="$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 lsblk 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | awk '($4 == "10G" && $6 == "disk") {count++} END {print count}')"

if [ "$diskcont" == "" ]
then
    echo false
    exit 0
fi


if [ "$diskcont" -lt 2 ]
then
    echo false
    exit 0
fi

echo true

#set +e

exit 0

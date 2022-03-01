#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi


if [ $(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 'sudo docker ps --format "table {{.Names}}" | grep -v "NAMES" | grep "img\|frontend\|text\|list" | sort | wc -l') != 4 ]
then
    echo false
    exit 0
fi

echo true
exit 0
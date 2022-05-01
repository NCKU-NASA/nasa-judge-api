#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 1
fi

pid=$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo ss -antlp | grep 0.0.0.0:80 | awk -F ',' '{print $2}' | cut -d '=' -f 2)
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo cat /proc/$pid/cmdline | grep -ao nginx)" = "" ]
then
    echo false
    exit 1
fi
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 curl -Ssi http://localhost | grep Server: | grep -o nginx)" = "" ]
then
    echo false
    exit 1
fi
echo true

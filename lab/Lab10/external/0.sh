#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 1
fi

# delete all keys first
python3 external/delete_all_keys.py $1

pid=$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo ss -antlp 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep 0.0.0.0:80 | awk -F ',' '{print $2}' | cut -d '=' -f 2)
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo cat /proc/$pid/cmdline 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep -ao nginx)" = "" ]
then
    echo false
    exit 1
fi
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 curl -Ssi http://localhost 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep Server: | grep -o nginx)" = "" ]
then
    echo false
    exit 1
fi
echo true

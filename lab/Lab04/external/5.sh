#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 cat /etc/mdadm/mdadm.conf | grep ARRAY | awk '{print $1 $2 $3}')" != "ARRAY/dev/md0level=raid0" ]
then
    echo false
    exit 0
fi

echo true
exit 0
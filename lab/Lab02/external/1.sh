#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

# frontend -> text
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t frontend ping text -c 1 -W 1 | grep -P "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi
# text -> list
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t text ping list -c 1 -W 1 | grep -P "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi
# img -> list
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t img ping list -c 1 -W 1 | grep "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi


echo true
exit 0
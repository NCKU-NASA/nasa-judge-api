#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

# frontend -> text
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t frontend ping text -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep -P "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi
# frontend -> list
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t frontend ping list -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep -P "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi
# text -> list
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t text ping list -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep -P "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi
# img -> list
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker exec -t img ping list -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "64 bytes from .* \(.*\): icmp_seq=1")" == '' ]
then
    echo false
    exit 0
fi

echo true

#set +e

exit 0

#!/bin/bash
if [ $# -lt 3 ]
then
    echo "usage: $0 <wanip> <studentId> <userName>"
    exit 0
fi

#set -e

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo gpasswd -d $3 sudo 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog 1> /dev/null

sleep 4;
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 groups "$3" 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep sudo)" == "" ]
then
    ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo usermod -aG sudo "$3" 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog 1> /dev/null
    echo false
    exit 0
fi

echo true

#set +e

exit 0

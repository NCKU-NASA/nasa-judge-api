#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

# frontend (8080:8083)
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker port frontend 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep -P "8083\/.* -> 0\.0\.0\.0:8080")" == '' ]
then
    echo false
    exit 0
fi

# img (8081:8081)
if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo docker port img 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep -P "8081\/.* -> 0\.0\.0\.0:8081")" == '' ]
then
    echo false
    exit 0
fi


echo true

#set +e

exit 0

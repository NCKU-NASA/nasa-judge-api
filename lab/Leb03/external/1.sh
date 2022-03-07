#!/bin/bash
if [ $# -lt 3 ]
then
    echo "usage: $0 <wanip> <studentId> <servicesName>"
    exit 0
fi


if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo systemctl list-units | grep $3)" == "" ]
then
    echo false
    exit 0
fi


echo true
exit 0
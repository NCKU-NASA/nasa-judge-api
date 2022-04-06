#!/bin/bash

if [ $# -lt 2 ]
then
   echo "usage: $0 <wanip> <studentId>"
   exit 0
fi

userneedtest=$(shuf -n 3 userbag)

for user in ${userneedtest[@]};
do
    if [ "$(ssh $(echo "$user" | awk '{print tolower($0)}')@$1 whoami)" != "$user" ]
    then
        echo false
        exit 0
    fi
done


# TODO
# 1. remove user from student computer with userbag
# 2. remove group from student computer with groupbag

echo true


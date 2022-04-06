#!/bin/bash

if [ $# -lt 2 ]
then
   echo "usage: $0 <wanip> <studentId>"
   exit 0
fi

# generate user config
bash ../genuserconfig.sh
scp ./userconfig $(echo "$2" | awk '{print tolower($0)}')@$1:/usr/local/bin/

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "/usr/local/bin/genuserconfig.sh /usr/local/bin/userconfig"

userneedtest=$(shuf -n 50 userbag)

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "
for user in $userneedtest;
do
    
done
"

# TODO
# 1. test id with for loop

echo true


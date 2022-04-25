#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e


if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo apt list --installed ncat netcat* 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep installed)" == "" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 type nc 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" == "" ]
then
    echo false
    exit 0
fi


port=$(shuf -i 2000-40000 -n 1)

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "echo dead | nc -l -p $port" 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog 1>/dev/null &

sleep 1

if [ "$(echo 1 | nc $1 $port -q 1 -w 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "" ]
then
    echo false
    exit 0
fi

kill -9 $(ps aux | grep "echo dead | nc -l -p $port" | awk '{print $2}' | head -n 1)

for a in $(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ps aux | grep "nc -l -p $port" | awk '{print $2}')
do
    ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "kill -9 $a"
done

echo true

#set +e

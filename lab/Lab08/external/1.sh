#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo whoami 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "root" ]
then
    echo "passwd free sudo?" >> judgelog
    echo false
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo apt list --installed ncat netcat* 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep installed)" == "" ]
then
    echo "Please install netcat." >> judgelog
    echo false
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 type nc 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" == "" ]
then
    echo false
    exit 0
fi



port=$(shuf -i 2000-40000 -n 1)

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "echo \"if you see this message, your external/1 fail\" | sudo nc -l -p $port" 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog 1>/dev/null &

sleep 3

dead=false
if [ "$(echo 1 | nc $1 $port -q 1 -w 3 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "" ]
then
    echo false
    dead=true
fi

kill -9 $(ps aux | grep "nc -l -p" | awk '{print $2}' | head -n 1)

if ! $dead
then
    port=80

    ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "echo \"80 port?\" | sudo nc -l -p $port" 1>/dev/null &

    sleep 3

    if [ "$(echo 1 | nc $1 $port -q 1 -w 3 | tee -a judgelog)" != "" ]
    then
        echo false
        dead=true
    fi
fi

kill -9 $(ps aux | grep "nc -l -p" | awk '{print $2}' | head -n 1)

for a in $(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ps aux | grep "nc -l -p" | awk '{print $2}')
do
    ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "sudo kill -9 $a"
done

if $dead
then
    exit 0
fi

echo true

#set +e

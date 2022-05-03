#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 hostname 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "clt" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ping clt -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from clt (.*): icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ip a show eth0 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "inet " | wc -l)" == "" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ip a show eth0 | grep "inet 192\.168\.3\.100/24")" == "" ]
then
    echo false
    exit 0
fi


echo true

#set +e

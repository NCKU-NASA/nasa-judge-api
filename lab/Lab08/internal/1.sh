#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ping 8.8.8.8 -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi

traceroutedata="$(ssh $username@$1 ssh $username@192.168.3.100 traceroute -n -I 8.8.8.8 -w 0.1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)"

if [ "$(echo "$traceroutedata" | grep "1  192.168.3.254")" == "" ]
then
    echo false
    exit 0
fi

if [ "$(echo "$traceroutedata" | grep "2  10.100.100.254")" == "" ]
then
    echo false
    exit 0
fi

echo true

#set +e

#!/bin/bash

if [ $# -lt 3 ]
then
    echo "usage: $0 <wanip> <studentId> <password>"
    exit 0
fi

if [ "$(sshpass -p $3 ssh $2@$1 ping 8.8.8.8 -c 1 -W 1 | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi

echo true


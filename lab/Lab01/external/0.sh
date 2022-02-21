#!/bin/bash

#if [ $# -lt 1 ]
#then
#    echo "usage: $0 <clt ip>"
#    exit 0
#fi

if [ "$(ping 8.8.8.8 -c 1 -W 1 | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi

echo true


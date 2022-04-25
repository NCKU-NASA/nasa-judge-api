#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 hostname 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "gw" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ping gw -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from gw (.*): icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ip a show lan 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "inet 192\.168\.3\.254/24")" == "" ]
then
    echo false
    exit 0
fi

if [ "$(ping $1 -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from $1: icmp_seq=1")" == "" ]
then
    echo false
    exit 0
fi


echo true

#set +e

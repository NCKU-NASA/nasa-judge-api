#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: 3.sh <username> <client wan ip>"
    exit 0
fi

if [ "$(dig @$2 www.$1.finalexam.ncku +time=1 +tries=1 | grep "192.168")" != "" ]
then
    echo false
    exit 0
fi

if [ "$(dig @$2 vpn.$1.finalexam.ncku +time=1 +tries=1 | grep "192.168")" != "" ]
then
    echo false
    exit 0
fi

echo true


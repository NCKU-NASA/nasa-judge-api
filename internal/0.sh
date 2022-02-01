#!/bin/bash

if [ $# -eq 0 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

if [ "$(dig @192.168.140.254 www.$1.finalexam.ncku +time=1 +tries=1 | grep "connection timed out")" != "" ]
then
    echo false
    exit 0
fi
echo true

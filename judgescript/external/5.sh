#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

if [ "$(curl --connect-timeout 1 -L --HEAD https://www.$1.finalexam.ncku --cacert ca.crt | grep -P "HTTP/\d.\d 200")" == "" ]
then
    echo false
    exit 0
fi
echo true


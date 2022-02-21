#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

if [ "$(curl --connect-timeout 1 --HEAD http://www.$1.finalexam.ncku | grep "Location: https:")" == "" ]
then
    echo false
    exit 0
fi

echo true


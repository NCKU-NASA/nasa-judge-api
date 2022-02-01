#!/bin/bash

if [ $# -eq 0 ]
then
    echo "usage: 1.sh <username>"
    exit 0
fi

if [ $(curl -L -k http://www.$1.finalexam.ncku | wc -l) -eq 0 ] && [ "$(curl -L -k http://www.$1.finalexam.ncku 2>&1 | grep "curl: (")" != "" ]
then
    echo false
    exit 0
fi

if [ $(curl -L -k https://www.$1.finalexam.ncku | wc -l) -eq 0 ] && [ "$(curl -L -k https://www.$1.finalexam.ncku 2>&1 | grep "curl: (")" != "" ]
then
    echo false
    exit 0
fi
echo true

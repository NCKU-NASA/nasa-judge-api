#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

if [ "$(curl --HEAD -L https://www.$1.finalexam.ncku/auth -k | grep -P "HTTP/\d.\d 401")" == "" ]
then
    echo false
    exit 0
fi

if [ "$(curl --HEAD -L https://www.$1.finalexam.ncku/auth -k --user WEB$(printf "%02d" $(shuf -i 1-50 -n 1)):finalexam | grep -P "HTTP/\d.\d 200")" == "" ]
then
    echo false
    exit 0
fi
echo true


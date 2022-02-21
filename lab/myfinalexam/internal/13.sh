#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <clt ip>"
    exit 0
fi

if [ "$(sshpass -p finalexam ssh root@$1 df | grep "finalexam.ncku:/share" | grep "/srv2nfs")" == "" ]
then
    echo false
    exit 0
fi
echo true


#!/bin/bash

#if [ $# -lt 1 ]
#then
#    echo "usage: $0 <username>"
#    exit 0
#fi

if [ "$(sshpass -p finalexam ssh root@192.168.140.2 showmount -e | grep /share)" == "" ]
then
    echo false
    exit 0
fi
echo true


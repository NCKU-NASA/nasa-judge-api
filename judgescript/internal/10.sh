#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <clt ip>"
    exit 0
fi

if [ "$(sshpass -p finalexam ssh root@$1 cat /etc/passwd | grep -P "(USER|WEB)")" != "" ]
then
    echo false
    exit 0
fi
if [ "$(sshpass -p finalexam ssh root@$1 getent passwd | grep -P "(USER|WEB)")" == "" ]
then
    echo false
    exit 0
fi
echo true


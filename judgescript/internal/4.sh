#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

if [ "$(ldapsearch -l 1 -h ldap.$1.finalexam.ncku -D "cn=admin,dc=$1,dc=finalexam,dc=ncku" -w finalexam -b "dc=$1,dc=finalexam,dc=ncku" "(uid=WEB$(printf "%02d" $(shuf -i 1-50 -n 1)))" -LLL)" == "" ]
then
    echo false
    exit 0
fi

echo true


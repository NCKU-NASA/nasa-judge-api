#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <clt ip>"
    exit 0
fi

if [ "$(sshpass -p finalexam ssh root@$1 "grep dhcp-server-identifier /var/lib/dhcp/dhclient.*.leases" | grep 192.168.140.254)" == "" ]
then
    echo false
    exit 0
fi

if [ "$(sshpass -p finalexam ssh root@$1 ip a | grep dynamic)" == "" ]
then
    echo false
    exit 0
fi

echo true


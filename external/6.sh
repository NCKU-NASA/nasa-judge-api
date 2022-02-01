#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

cp ca.crt /etc/ipsec.d/cacerts/ca.crt

sed -i "s/right=.*/right=vpn.$1.finalexam.ncku/g" /etc/ipsec.conf

systemctl restart strongswan-starter.service

sleep 0.5

if [ "$(ipsec status | grep "ikevpn\[1\]")" == "" ]
then
    echo false
    exit 0
fi
echo true


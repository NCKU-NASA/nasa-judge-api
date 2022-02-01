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
sed -i "s/192.168.123.254/192.168.140.254/g" /etc/resolv.conf
echo true


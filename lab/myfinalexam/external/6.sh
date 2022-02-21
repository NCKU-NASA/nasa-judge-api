#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

cp ca.crt /etc/ipsec.d/cacerts/ca.crt

cp ipsec.secrets /etc/ipsec.secrets

sed "s/right=.*/right=vpn.$1.finalexam.ncku/g" ipsec.conf > /etc/ipsec.conf

systemctl restart strongswan-starter.service

sleep 0.5

sed -i "s/192.168.123.254/192.168.140.254/g" /etc/resolv.conf

if [ "$(ipsec status | grep "ikevpn\[1\]")" == "" ]
then
    echo false
    exit 0
fi
echo true

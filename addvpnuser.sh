#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

bash /etc/wireguard/addwguser.sh -s /etc/wireguard/server.conf -u $1 -f nasajudge.chummydns.com -r 0.0.0.0/0 -ns 10.100.100.254

userip=$(grep -B 1 -A 3 "# $1" /etc/wireguard/server.conf | grep -oP '(?<=AllowedIPs\s=\s)\d+(\.\d+){3}\/.*' | tail -n 1)

bash /etc/wireguard/addwguser.sh -s /etc/wireguard/testserver.conf -u $1 -f nasajudge.chummydns.com -r $userip,10.100.200.254/32 -d client2 -a 10.100.200.$(echo $userip | sed 's/.*\.//g' | sed 's/\/.*//g') -ns 10.100.200.254

cp /etc/wireguard/client/$1.conf /etc/nasajudgeserver/files/$1/wireguard.conf

cp /etc/wireguard/client2/$1.conf /etc/nasajudgeserver/files/$1/testwireguard.conf

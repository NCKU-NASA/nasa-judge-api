#!/bin/bash

if [ $# -lt 3 ]
then
    echo "usage: $0 <wanip> <min> <max>"
    exit 0
fi


> /etc/nasajudgeapi/node.conf

for a in $(seq $2 1 $3)
do 
    ping $(echo $1 | sed 's/[0-9]*$//g')$a -c 1 -w 1 | grep -P "64 bytes from .*: icmp_seq=1 ttl=64" | sed 's/64 bytes from //g' | sed 's/: icmp_seq=1 ttl=64.*//g' >> /etc/nasajudgeapi/node.conf
done


#nmap -sP 192.168.123.0/24 | grep "Nmap scan report for" | sed 's/Nmap\ scan\ report\ for\ //g' | sed '/192\.168\.123\.254/d' > /etc/nasajudgeapi/node.conf

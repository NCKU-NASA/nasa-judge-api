#!/bin/bash

> /etc/nasajudgeserver/node.conf

for a in $(seq 100 1 200)
do 
    ping 192.168.123.$a -c 1 -w 1 | grep -P "64 bytes from .*: icmp_seq=1 ttl=64" | sed 's/64 bytes from //g' | sed 's/: icmp_seq=1 ttl=64.*//g' >> /etc/nasajudgeserver/node.conf
done


#nmap -sP 192.168.123.0/24 | grep "Nmap scan report for" | sed 's/Nmap\ scan\ report\ for\ //g' | sed '/192\.168\.123\.254/d' > /etc/nasajudgeserver/node.conf

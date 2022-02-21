#!/bin/bash

nmap -sP 192.168.123.0/24 | grep "Nmap scan report for" | sed 's/Nmap\ scan\ report\ for\ //g' | sed '/192\.168\.123\.254/d' > /etc/nasajudgeserver/node.conf

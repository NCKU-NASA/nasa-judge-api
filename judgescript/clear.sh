#!/bin/bash
sed -i "s/192.168.140.254/192.168.123.254/g" /etc/resolv.conf
sed -i "s/8.8.8.8/192.168.123.254/g" /etc/resolv.conf
> ~/.ssh/known_hosts
systemctl stop strongswan-starter.service

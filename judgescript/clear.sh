#!/bin/bash
sed -i "s/192.168.140.254/192.168.123.254/g" /etc/resolv.conf
systemctl stop strongswan-starter.service

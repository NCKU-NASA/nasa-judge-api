#!/bin/bash

runonhost=false

if [ "$1" == "true" ]
then
    runonhost=true
fi

if $runonhost
then
    true
else
    mkdir ~/.ssh
    echo "StrictHostKeyChecking no" > ~/.ssh/config
    echo "UserKnownHostsFile=/dev/null" >> ~/.ssh/config
    echo "PasswordAuthentication=no" >> ~/.ssh/config
    echo "ConnectTimeout=1" >> ~/.ssh/config
    echo "domain chummydns.com
search chummydns.com
nameserver 192.168.123.254
options timeout:1" > /etc/resolv.conf
fi

apt-get update > /dev/null

allpackage=$(apt list --installed | sed "s/\/.*//g")

for a in $(cat package.conf)
do
    if [ "$(echo "$allpackage" | grep -P "^$a\$")" == "" ]
    then
        apt-get install -y $a > /dev/null 
        echo "domain chummydns.com
search chummydns.com
nameserver 192.168.123.254
options timeout:1" > /etc/resolv.conf
    fi
done

if $runonhost
then
    true
else
    echo "domain chummydns.com
search chummydns.com
nameserver 192.168.123.254
options timeout:1" > /etc/resolv.conf
fi

#your code must write here






if [ -f start.sh ]
then
    bash start.sh $@
fi

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
    echo "domain chummydns.com
search chummydns.com
nameserver 192.168.123.254
options timeout:1" > /etc/resolv.conf
    > ~/.ssh/known_hosts
fi


#your code must write here

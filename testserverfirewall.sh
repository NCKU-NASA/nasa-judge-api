#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <up|down>"
    exit 0
fi

case "$1" in
    up)
        mode="-A"
        ;;
    down)
        mode="-D"
        ;;
    *)
        echo "bad arg..."
        exit 0
        ;;
esac

if [ "$mode" != "" ]
then
    for a in $(seq 1 1 253)
    do
        iptables $mode FORTESTSERVER -s 10.100.200.$a -d 10.100.100.$a -j ACCEPT
    done
    
    iptables $mode FORTESTSERVER -s 10.100.200.38 -j ACCEPT
    iptables $mode FORTESTSERVER -s 10.100.200.37 -j ACCEPT
    iptables $mode FORTESTSERVER -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables $mode FORTESTSERVER -j DROP
fi


#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $0 <username>"
    exit 0
fi

if [ "$1" == "public" ]
then
    echo "no public"
    exit 0
fi

if [ "$(grep "# $1" /etc/wireguard/server.conf)" != "" ]
then
    echo "User exist"
else
    bash /etc/wireguard/addwguser.sh -s /etc/wireguard/server.conf -u $1 -f nasajudge.chummydns.com -r 0.0.0.0/0 -ns 10.100.100.254
    sed -i '4 aPostUp = iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu' /etc/wireguard/client/$1.conf
    sed -i '5 aPostUp = bash -c "for a in \\$(seq 1 1 \\$(iptables-save | grep \\"\\\\\\"wg-quick(8) rule for %i\\\\\\" -j DROP\\" | sed '"'"'s/-A/-D/g'"'"' | wc -l)); do bash -c \\\"iptables -t raw \\$(iptables-save | grep \\\"\\\\\\"wg-quick(8) rule for %i\\\\\\" -j DROP\\\" | sed '"'"'s/-A/-D/g'"'"' | head -n 1)\\\"; done"' /etc/wireguard/client/$1.conf
    sed -i '6 aPostDown = bash -c "for a in \\$(seq 1 1 \\$(sudo iptables-save | grep \\"\\\\-A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu\\" | wc -l)); do iptables -t mangle -D FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu; done"' /etc/wireguard/client/$1.conf
    sed -i '7 aMTU = 1420' /etc/wireguard/client/$1.conf
fi

userip=$(grep -B 1 -A 3 "# $1" /etc/wireguard/server.conf | grep -oP '(?<=AllowedIPs\s=\s)\d+(\.\d+){3}\/.*' | tail -n 1)

if [ "$(grep "# $1" /etc/wireguard/testserver.conf)" != "" ]
then
    echo "User exist"
else
    bash /etc/wireguard/addwguser.sh -s /etc/wireguard/testserver.conf -u $1 -f nasajudge.chummydns.com -r $userip,10.100.200.254/32 -d client2 -a 10.100.200.$(echo $userip | sed 's/.*\.//g' | sed 's/\/.*//g') -ns 10.100.200.254
    sed -i '4 aMTU = 1420' /etc/wireguard/client2/$1.conf
fi

mkdir /tmp/nasa

cd /tmp/nasa

cp /etc/wireguard/client/$1.conf wan.conf

cp /etc/wireguard/client2/$1.conf testvpn.conf

zip wireguard *

cp wireguard.zip /etc/nasajudgeapi/files/$1/wireguard.zip

cd ~
rm -r /tmp/nasa


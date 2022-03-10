#!/bin/bash
cd /tmp

rm -r nasa-judge-api

git clone https://github.com/NCKU-NASA/nasa-judge-api

cd nasa-judge-api

for a in $(ls -a)
do
    if [ "$a" != "." ] && [ "$a" != ".." ] && [ "$a" != ".git" ] && [ "$a" != "README.md" ] && [ "$a" != "install.sh" ] && [ "$a" != "remove.sh" ] && [ "$a" != "setupdefaultiptables.sh" ] && [ "$a" != "iptablesconf.conf" ] && [ "$a" != "setupgit.sh" ] && [ "$a" != "db.conf" ]
    then
        rm -rf $a
    fi
done

for a in $(ls -a /etc/nasajudgeapi)
do
    if [ "$a" != "." ] && [ "$a" != ".." ] && [ "$(cat /etc/nasajudgeapi/.gitignore | sed 's/\/.*//g' | sed '/^!.*/d' | grep -P "^$(echo "$a" | sed 's/\./\\\./g')$")" == "" ]
    then
        sudo cp -r /etc/nasajudgeapi/$a $a
    fi
done

sudo cp -r /etc/wireguard/testserverfirewall.sh testserverfirewall.sh

> node.conf

sudo cp /etc/systemd/system/nasajudgeapi.service nasajudgeapi.service
sudo cp /etc/systemd/system/nasajudgesql.service nasajudgesql.service

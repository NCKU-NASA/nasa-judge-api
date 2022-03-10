#!/bin/bash
cd /tmp

rm -r nasa-judge-api

git clone https://github.com/NCKU-NASA/nasa-judge-api

cd nasa-judge-api

for a in $(ls -a)
do
    if [ "$a" != "." ] && [ "$a" != ".." ] && [ "$a" != ".git" ] && [ "$a" != "README.md" ] && [ "$a" != "install.sh" ] && [ "$a" != "setupgit.sh" ]
    then
        rm -rf $a
    fi
done

for a in $(ls -a /etc/nasajudgeserver)
do
    if [ "$a" != "." ] && [ "$a" != ".." ] && [ "$(cat /etc/nasajudgeserver/.gitignore | sed 's/\/.*//g' | sed '/^!.*/d' | grep -P "^$(echo "$a" | sed 's/\./\\\./g')$")" == "" ]
    then
        cp -r /etc/nasajudgeserver/$a $a
    fi
done

cp -r /etc/wireguard/testserverfirewall.sh testserverfirewall.sh

> node.conf

cp /lib/systemd/system/nasajudgeserver.service nasajudgeserver.service

#!/bin/bash

if [ $# -lt 2 ]
then
   echo "usage: $0 <wanip> <studentId>"
   exit 0
fi

#set -e

# generate user config
bash genuserconfig.sh

userconfigname=$(xxd -l 8 -ps /dev/urandom)

scp userconfig $(echo "$2" | awk '{print tolower($0)}')@$1:/tmp/$userconfigname 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "
for group in $(cat groupbag)"'
do
    sudo groupadd $group
done
' 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "sudo addallusers.sh /tmp/$userconfigname; rm /tmp/$userconfigname" 2> >(tee -a judgeerrlog 1>/dev/null) | tee -a judgelog 1>/dev/null

userneedtest="$(cat userbag)"

userid="$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "
for user in $userneedtest"'
do
    if [ "$(id $user 2>/dev/null)" != "" ]
    then
        echo $user
        id $user
    fi
done
' 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)"

for a in $userneedtest
do
    nowdata="$(echo "$userid" | grep -A 1 "^$a$" | tail -n 1 | sed 's/[0-9]*(/(/g')"

    if [ "$nowdata" == "" ]
    then
        echo false
        exit 0
    fi

    if [ "$(echo $nowdata | awk '{print $1}')" != "uid=($a)" ]
    then
        echo false
        exit 0
    fi

    if [ "$(echo $nowdata | awk '{print $2}')" != "gid=($a)" ]
    then
        echo false
        exit 0
    fi

    groups="$(cat userconfig | grep "^$a " | awk '{print $3}' | sed 's/,/ /g')"
    for b in $groups
    do
        if [ "$(echo $nowdata | awk '{print $3}' | grep "\($b\)")" == "" ]
        then
            echo false
            exit 0
        fi
    done
done


echo true

#set +e

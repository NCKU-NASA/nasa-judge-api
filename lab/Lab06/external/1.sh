#!/bin/bash

if [ $# -lt 2 ]
then
   echo "usage: $0 <wanip> <studentId>"
   exit 0
fi

#set -e

sed -i 's/PasswordAuthentication=no/PasswordAuthentication=yes/g' ~/.ssh/config
echo 'PubkeyAuthentication=no' >> ~/.ssh/config

userneedtest=$(cat userbag | sed 's/ /\n/g' | shuf -n 3)

bad=false
for user in ${userneedtest[@]};
do
    if [ "$(sshpass -p $(cat userconfig | grep "^$user " | awk '{print $2}') ssh $(echo "$user" | awk '{print tolower($0)}')@$1 whoami 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "$user" ]
    then
        echo false
        bad=true
        break
    fi
done

sed -i 's/PasswordAuthentication=yes/PasswordAuthentication=no/g' ~/.ssh/config
sed -i '/PubkeyAuthentication=no/d' ~/.ssh/config

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "
for user in $(cat userbag)"'
do
    sudo userdel -rf $user 2>/dev/null
done
' 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "
for group in $(cat groupbag)"'
do
    sudo groupdel $group 2>/dev/null
done
' 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

if $bad
then
    exit 0
fi

echo true

#set +e

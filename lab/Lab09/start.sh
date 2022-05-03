#!/bin/bash


ssh $(echo "$3" | awk '{print tolower($0)}')@$2 '
if [ -f ~/.ssh/config ]
then
    cp ~/.ssh/config ~/.ssh/config.bak
else
    touch ~/.ssh/config.bak
fi

echo "StrictHostKeyChecking no" > ~/.ssh/config
echo "UserKnownHostsFile=/dev/null" >> ~/.ssh/config
echo "PasswordAuthentication=no" >> ~/.ssh/config
echo "ConnectTimeout=1" >> ~/.ssh/config
chmod 600 ~/.ssh/config'

#!/bin/bash

bash init.sh

pwddir=$(pwd)
rm -f /var/run/docker.pid
dockerd &
sleep 3s

cd global 
while ! docker compose up -d
do
    true
done
cd ..

./nasa-judge-api


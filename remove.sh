#!/bin/bash

sudo systemctl stop nasajudgeapi.service
sudo systemctl disable nasajudgeapi.service

sudo rm /etc/systemd/system/nasajudgeapi.service

sudo umount /etc/nasajudgeapi/files

for filename in addvpnuser.sh db.conf files lab node.conf finaluserlist.conf __pycache__ requirements.txt server.py server.sh setupnode.sh testcheck.py testlab.json venv
do
	sudo rm -r /etc/nasajudgeapi/$filename
done

sudo mv /etc/nasajudgeapi/server.key .
sudo mv /etc/nasajudgeapi/server.crt .

if [ "`ls /etc/nasajudgeapi`" = "" ]
then
	rm -r /etc/nasajudgeapi
fi

echo ""
echo ""
echo "NASA Judge API Service remove.sh complete."

for filename in server.key server.crt
do
	echo "Your ${filename} is at $(pwd)/${filename}."
done

echo "If you don't need then, please delete then."

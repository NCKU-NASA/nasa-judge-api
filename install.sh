#!/bin/bash

set -e

dirpath=$(dirname "$0")

ansible-galaxy collection install -r $dirpath/requirements.yml -f
ansible-galaxy role install -r $dirpath/requirements.yml -f
ansible-playbook $dirpath/setup.yml

echo ""
echo ""
echo "NASA Judge API Service install.sh complete."
echo "Fix your config file at /etc/nasajudegapi/config.yaml"
echo "Then you can use systemctl start nasajudgeapi.service to start the service"
echo "If you want to auto run on boot please type 'systemctl enable nasajudgeapi.service'"

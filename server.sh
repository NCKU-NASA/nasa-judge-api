#!/bin/bash

workdir="/etc/nasajudgeserver"

. ./venv/bin/activate

#python server.py
gunicorn --bind [::]:80 server:app -k gevent --worker-connections 80 --timeout 300
#gunicorn --certfile=server.crt --keyfile=server.key --bind [::]:443 server:app

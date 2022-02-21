#!/bin/bash

workdir="/etc/nasajudgeserver"

. ./venv/bin/activate

#python server.py
gunicorn --bind [::]:80 server:app --timeout 300
#gunicorn --certfile=server.crt --keyfile=server.key --bind [::]:443 server:app

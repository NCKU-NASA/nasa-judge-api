#!/bin/bash

workdir="/etc/nasajudgeserver"

. ./venv/bin/activate

gunicorn --bind [::]:80 server:app
#gunicorn --certfile=server.crt --keyfile=server.key --bind [::]:443 server:app

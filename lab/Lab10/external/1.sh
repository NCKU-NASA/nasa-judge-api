#!/bin/bash

python3 external/cannot_login.py $1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

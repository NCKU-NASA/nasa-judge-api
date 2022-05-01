#!/bin/bash

python3 external/can_logout.py $1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

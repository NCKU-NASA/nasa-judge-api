#!/bin/bash

python3 external/can_update_key.py $1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

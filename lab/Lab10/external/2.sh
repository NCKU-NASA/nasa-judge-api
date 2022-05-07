#!/bin/bash

python3 external/can_get_all_keys.py $1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

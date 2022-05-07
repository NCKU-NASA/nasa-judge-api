#!/bin/bash

python3 external/key_not_found.py $1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog

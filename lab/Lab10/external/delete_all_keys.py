#!/usr/bin/env python3
'''
This script deletes all keys
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
  print('Usage: ./script <ip>', file=sys.stderr)
  sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

for key in utils.getAll(base_url):
  utils.delete(base_url, key)

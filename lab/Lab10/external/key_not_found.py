#!/usr/bin/env python3
'''
This script checks if quering non-exist key returns 404
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
  print('Usage: ./script <ip>', file=sys.stderr)
  sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

chars = string.ascii_letters + string.digits
key = ''.join(random.choice(chars) for x in range(50))
if utils.get(base_url, key).get(key) == None:
  print('true')
else:
  print('false')
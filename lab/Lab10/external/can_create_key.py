#!/usr/bin/env python3
'''
This script checks if key can be successfully created and queried
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
  print('Usage: ./script <ip>', file=sys.stderr)
  sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'
key, value = '', ''

for pair in open('external/key_value_pair.lst', 'r'):
  try:
    key, value = pair.strip().split(':')
    if utils.create(base_url, key, value) == 201:
      if utils.get(base_url, key).get(key) == value:
        continue
      else:
        print(f'Incorrect value for key "{key}"', file=sys.stderr)
    else:
      print(f'Return status for create key "{key}" is incorrect', file=sys.stderr)
  except Exception as e:
    print(e, file=sys.stderr)
  print('false')
  sys.exit(1)
if utils.create(base_url, key, value) != 400:
  print(f'Return status for duplicate key is incorrect', file=sys.stderr)
  print('false')
else:
  print('true')

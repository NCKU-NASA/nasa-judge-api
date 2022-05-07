#!/usr/bin/env python3
'''
This script checks if keys can be listed
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
  print('Usage: ./script <ip>', file=sys.stderr)
  sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

keys = utils.getAll(base_url)
for pair in open('external/key_value_pair.lst', 'r'):
  try:
    key, value = pair.strip().split(':')
    if key in keys:
      continue
    else:
      print(f'Cannot find key "{key}"', file=sys.stderr)
  except Exception as e:
    print(e, file=sys.stderr)
  print('false')
  sys.exit(1)
print('true')

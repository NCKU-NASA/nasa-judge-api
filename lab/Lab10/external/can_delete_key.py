#!/usr/bin/env python3
'''
This script checks if key can be successfully deleted
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
  print('Usage: ./script <ip>', file=sys.stderr)
  sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

for pair in open('external/key_value_pair.lst', 'r'):
  try:
    key, value = pair.strip().split(':')
    if utils.get(base_url, key).get(key) == value: 
      if utils.delete(base_url, key) == 200:
        if utils.get(base_url, key).get(key) == None:
          continue
        else:
          print(f'The key "{key}" was not successfully deleted', file=sys.stderr)
      else:
        print(f'Return status for delete key "{key}" is incorrect', file=sys.stderr)
    else:
      print(f'Incorrect value for key "{key}"', file=sys.stderr)
  except Exception as e:
    print(e, file=sys.stderr)
  print('false')
  sys.exit(1)
print('true')

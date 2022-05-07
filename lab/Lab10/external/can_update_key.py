#!/usr/bin/env python3
'''
This script checks if key can be updated
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
  print('Usage: ./script <ip>', file=sys.stderr)
  sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

chars = string.ascii_letters + string.digits + string.punctuation
for i in range(5):
  try:
    key = ''.join(random.choice(chars) for x in range(50))
    value = ''.join(random.choice(chars) for x in range(50))
    change = ''.join(random.choice(chars) for x in range(10))
    updateValue = value + change
    if utils.update(base_url, key, value) == 201:
      if utils.get(base_url, key).get(key) == value:
        if utils.update(base_url, key, updateValue) == 200:
          if utils.get(base_url, key).get(key) == updateValue:
            continue
          else:
            print('Value not updated', file=sys.stderr)
        else:
          print('Return status for update is not correct. It should be 200.', file=sys.stderr)
      else:
        print('Cannot get the newly created resource', file=sys.stderr)
    else:
      print('Return status for update is not correct. It should be 201 (new resource created).', file=sys.stderr)
  except Exception as e:
    print(e, file=sys.stderr)
  print('false')
  sys.exit(1)
print('true')
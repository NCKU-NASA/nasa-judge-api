#!/usr/bin/env python3
'''
This script checks if a non-exist user can login
'''
import requests, sys, random, string
import utils

if len(sys.argv) != 2:
    print('Usage: ./script <ip>', file=sys.stderr)
    sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

chars = string.ascii_letters + string.digits
username = ''.join(random.choice(chars) for x in range(20))
password = ''.join(random.choice(chars) for x in range(20))
try:
    sess = requests.Session()
    status = utils.login(sess, base_url, {'username': username, 'password': password})
except Exception as e:
    print(e, file=sys.stderr)
if status != 401:
    print('Status code 401 expected', file=sys.stderr)
    print('false')
else:
    print('true')

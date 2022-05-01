#!/usr/bin/env python3
'''
This script checks whether client can login and get user data
'''
import requests, sys
import utils

if len(sys.argv) != 2:
    print('Usage: ./script <ip>', file=sys.stderr)
    sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

for credential in open('credential.lst', 'r'):
    try:
        username, password = credential.strip().split(':')
        sess = requests.Session()
        credential = {'username': username, 'password': password}
        utils.register(base_url, credential)
        if utils.login(sess, base_url, credential) == 200:
            body = utils.get_user(sess, base_url)
            if isinstance(body, dict) and body['username'] == username:
                continue
    except Exception as e:
        print(e, file=sys.stderr)
    print('false')
    sys.exit(1)
print('true')

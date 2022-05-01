#!/usr/bin/env python3
'''
This script checks whether client can delete his own account
'''
import requests, sys
import utils

if len(sys.argv) != 2:
    print('Usage: ./script <ip>', file=sys.stderr)
    sys.exit(1)
ip = sys.argv[1]
base_url = f'http://{ip}'

for credential in open('external/credential.lst', 'r'):
    try:
        username, password = credential.strip().split(':')
        sess = requests.Session()
        credential = {'username': username, 'password': password}
        utils.register(base_url, credential)
        if utils.login(sess, base_url, credential) == 200:
            utils.delete_user(sess, base_url)
        if utils.login(sess, base_url, credential) == 401:
            continue
    except Exception as e:
        print(e, file=sys.stderr)
    print('false')
    sys.exit(1)
print('true')

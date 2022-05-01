#!/usr/bin/env python3
import requests, sys, json
timeout = 1

def login(sess, base_url, credential: dict):
    required = ['username', 'password']
    for r in required:
        if r not in credential:
            return None
    res = sess.post(f'{base_url}/user/login', json=credential, timeout=timeout)
    return res.status_code

def register(base_url, credential: dict):
    required = ['username', 'password']
    for r in required:
        if r not in credential:
            return None
    res = requests.post(f'{base_url}/user/register', json=credential, timeout=timeout)
    return res.status_code

def logout(sess, base_url):
    res = sess.post(f'{base_url}/user/logout', timeout=timeout)
    return res.status_code

def get_user(sess, base_url):
    res = sess.get(f'{base_url}/user', timeout=timeout)
    if res.status_code != 200:
        return None
    try:
        res_body = json.loads(res.text)
        return res_body
    except:
        print('Error parsing user body', file=sys.stderr)
        return None

def delete_user(sess, base_url):
    res = sess.delete(f'{base_url}/user', timeout=timeout)
    return res.status_code

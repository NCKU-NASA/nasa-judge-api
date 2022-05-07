#!/usr/bin/env python3
import requests, sys, json
timeout = 1

def create(base_url, key, value):
  res = requests.post(f'{base_url}/key', json={'key': key, 'value': value}, timeout=timeout)
  return res.status_code

def getAll(base_url):
  res = requests.get(f'{base_url}/key', timeout=timeout)
  try:
    keys = json.loads(res.text)
    return keys
  except:
    print('Error parsing body', file=sys.stderr)
    return None

def get(base_url, key):
  res = requests.get(f'{base_url}/key/{requests.utils.quote(key)}', timeout=timeout)
  if res.status_code == 404:
    return {}
  elif res.status_code == 200:
    key = json.loads(res.text)
    return key
  else:
    raise Exception(f'Unexpected status code: {res.status_code}, response: {res.text}')

def update(base_url, key, value):
  res = requests.put(f'{base_url}/key/{requests.utils.quote(key)}', json={'key': key, 'value': value}, timeout=timeout)
  return res.status_code

def delete(base_url, key):
  res = requests.delete(f'{base_url}/key/{requests.utils.quote(key)}', timeout=timeout)
  return res.status_code
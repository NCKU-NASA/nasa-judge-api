import sys
import os
import time
import json
import ipaddress
import re

if len(sys.argv) < 2:
    print("usage: python3 testcheck.py <getdata.json file>")
    exit()


with open('node.conf', 'r') as f:
    nodes = f.read().split()

with open(sys.argv[1], 'r') as f:
    data = json.loads(f.read())

with open('lab/' + data['labId'] + '/data.json', 'r') as f:
    labdata = json.loads(f.read())
if not labdata['checkonhost']:
    while len(nodes) <= 0:
        time.sleep(0.1)
    nownode = nodes.pop(0)

try:
    data['wanip'] = os.popen('grep -B 1 -A 3 "# ' + data['studentId'] + '" /etc/wireguard/server.conf | grep -oP \'(?<=AllowedIPs\s=\s)\d+(\.\d+){3}\' | tail -n 1').read().strip()
    if labdata['checkonhost']:
        os.system('rm -r /tmp/judgescript')
        os.system('cp -r lab/' + data['labId'] + ' /tmp/judgescript')
        if not os.path.isfile('lab/' + data['labId'] + '/judge.py'):
            os.system('cp judge.py /tmp/judgescript/judge.py')
        with open('/tmp/judgescript/getdata.json', 'w') as f:
            f.write(json.dumps(data))
        getans = os.popen('cd /tmp/judgescript/; python3 judge.py; cd /tmp; rm -r judgescript"').read().strip()
    else:
        with open('/tmp/getdata.json', 'w') as f:
            f.write(json.dumps(data))
        os.system('ssh root@' + nownode + ' rm -r judgescript')
        os.system('scp -r lab/' + data['labId'] + ' root@' + nownode + ':judgescript')
        if not os.path.isfile('lab/' + data['labId'] + '/judge.py'):
            os.system('scp judge.py root@' + nownode + ':judgescript/judge.py')
        os.system('scp ' + os.path.join('/tmp', 'getdata.json') + ' root@' + nownode + ':judgescript/getdata.json')
        getans = os.popen('ssh root@' + nownode + ' "cd judgescript/; python3 judge.py; cd ~; rm -r judgescript"').read().strip()
except:
    os.system('ssh root@' + nownode + ' "bash judgescript/clear.sh ' + str(labdata['checkonhost']) + '; rm -r judgescript"')
if not labdata['checkonhost']:
    nodes.append(nownode)
print(getans)

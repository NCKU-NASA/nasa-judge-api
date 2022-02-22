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


while len(nodes) <= 0:
    time.sleep(0.1)

nownode = nodes.pop()
try:
    data['wanip'] = os.popen('grep -B 1 -A 3 "# ' + data['studentId'] + '" /etc/wireguard/server.conf | grep -oP \'(?<=AllowedIPs\s=\s)\d+(\.\d+){3}\' | tail -n 1').read().strip()
    with open('/tmp/getdata.json', 'w') as f:
        f.write(json.dumps(data))
    os.system('ssh root@' + nownode + ' rm -r judgescript')
    os.system('scp -r lab/' + data['labId'] + ' root@' + nownode + ':judgescript')
    os.system('scp ' + os.path.join('/tmp', 'getdata.json') + ' root@' + nownode + ':judgescript/getdata.json')
    getans = os.popen('ssh root@' + nownode + ' "cd judgescript/; python3 judge.py"').read().strip()
    os.system('ssh root@' + nownode + ' rm -r judgescript')
except:
    os.system('ssh root@' + nownode + ' bash judgescript/clear.sh')
    os.system('ssh root@' + nownode + ' rm -r judgescript')
nodes.append(nownode)
print(getans)

import os
import sys
import json
import time
import sys
import base64

with open('data.json', 'r') as f:
    data = json.loads(f.read())

with open('getdata.json', 'r') as f:
    getdata = json.loads(f.read())


#getans = os.popen('bash external/0.sh chummy').read().strip()
#print(getans)


#if type(ipaddress.ip_address(request.form["cltip"])).__name__ != 'IPv4Address':
#    return 'error'

ans={'external':[],'internal':[]}
keys=list(ans.keys())

os.system('bash start.sh')
os.system('bash clear.sh')
try:
    for a in getdata['data']:
        if a['type'] == 'file':
            with open(a['name'], 'wb') as f:
                f.write(base64.b64decode(a['data'].encode("UTF-8")))
    
    for key in keys:
        if data.__contains__(key):
            for i in range(len(data[key])):
                nowargs = data[key][i]['args'].replace('<studentId>', getdata['studentId']).replace('<wanip>', getdata['wanip'])
                for a in getdata['data']:
                    if a['type'] == 'value':
                        nowargs = nowargs.replace('<' + a['name'] + '>', a['data'])

                print('bash ' + key + '/' + str(i) + '.sh ' + nowargs, file=sys.stderr)
                
                with open('/etc/resolv.conf', 'r') as f:
                    if 'timeout' not in f.read():
                        os.system('echo "options timeout:1" >> /etc/resolv.conf')
                
                getans = os.popen('bash ' + key + '/' + str(i) + '.sh ' + nowargs).read().strip()
                ans[key].append({'message': data[key][i]['message'],'ans': json.loads(getans.lower()), 'weight': data[key][i]['weight']})
except:
    os.system('bash clear.sh')
    print('false')
    exit()

#print(data)

os.system('bash clear.sh')

print(json.dumps(ans))
#os.system('pwd')

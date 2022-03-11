import os
import sys
import json
import time
import base64

with open('data.json', 'r') as f:
    data = json.loads(f.read())

with open('getdata.json', 'r') as f:
    getdata = json.loads(f.read())

#getans = os.popen('bash external/0.sh chummy').read().strip()
#print(getans)


#if type(ipaddress.ip_address(request.form["cltip"])).__name__ != 'IPv4Address':
#    return 'error'

checkonhost=data['checkonhost']

ans={'external':[],'internal':[]}
ansdb={'external':{},'internal':{}}
keys=list(ans.keys())


def judging(nowkey, index, checkpoint):
    canjudge = True
    if checkpoint.__contains__('check'):
        for key in keys:
            if checkpoint['check'].__contains__(key):
                for i in range(len(checkpoint['check'][key])):
                    if not ansdb[key].__contains__(checkpoint['check'][key][i]):
                        judging(key, checkpoint['check'][key][i], data[key][checkpoint['check'][key][i]])

        if checkpoint.__contains__('checkformula'):
            canjudge = eval(checkpoint['checkformula'])
        else:
            for key in keys:
                if checkpoint['check'].__contains__(key):
                    for i in range(len(checkpoint['check'][key])):
                        if not ansdb[key][checkpoint['check'][key][i]]['ans']:
                            checkjudge = False
                            break
                    if not checkjudge:
                        break

    if canjudge:
        nowargs = checkpoint['args'].replace('<studentId>', getdata['studentId']).replace('<wanip>', getdata['wanip']).replace('<labId>', getdata['labId'])
        for a in getdata['data']:
            if a['type'] == 'value':
                nowargs = nowargs.replace('<' + a['name'] + '>', a['data'])

        print(getdata['labId'] + ': bash ' + nowkey + '/' + str(index) + '.sh ' + nowargs, file=sys.stderr)
        
        if not checkonhost:
            with open('/etc/resolv.conf', 'r') as f:
                if 'timeout' not in f.read():
                    os.system('echo "options timeout:1" >> /etc/resolv.conf')
        
        getans = os.popen('bash ' + nowkey + '/' + str(index) + '.sh ' + nowargs).read().strip()
        ansdb[nowkey][index] = {'message': checkpoint['message'],'ans': json.loads(getans.lower()), 'weight': checkpoint['weight']}


os.system('bash start.sh ' + str(checkonhost))
os.system('bash clear.sh ' + str(checkonhost))
try:
    for a in getdata['data']:
        if a['type'] == 'file':
            with open(a['name'], 'wb') as f:
                f.write(base64.b64decode(a['data'].encode("UTF-8")))
    
    for key in keys:
        if data.__contains__(key):
            for i in range(len(data[key])):
                judging(key, i, data[key][i])

    for key in keys:
        if data.__contains__(key):
            for i in range(len(data[key])):
                ans[key].append(ansdb[key][i])

except Exception as ex:
    os.system('bash clear.sh ' + str(checkonhost))
    print(ex, file=sys.stderr)
    print('false')
    exit()

#print(data)

os.system('bash clear.sh ' + str(checkonhost))

print(json.dumps(ans))
#os.system('pwd')

import os
import sys
import json
import time

if len(sys.argv) < 4:
    print("usage: python3 judge.py <username> <client wan ip> <clt ip>")
    exit()


with open('data.json', 'r') as f:
    data = json.loads(f.read())

#getans = os.popen('bash external/0.sh chummy').read().strip()
#print(getans)

ans={'external':[],'internal':[]}
keys=list(ans.keys())

for key in keys:
    for i in range(len(data[key])):
        nowargs = data[key][i]['args'].replace('<username>', sys.argv[1]).replace('<client wan ip>', sys.argv[2]).replace('<clt ip>', sys.argv[3])


        getans = os.popen('bash ' + key + '/' + str(i) + '.sh ' + nowargs).read().strip()
        ans[key].append({'message': data[key][i]['message'],'ans': json.loads(getans.lower())})

#print(data)

os.system('bash clear.sh')

print(json.dumps(ans))
#os.system('pwd')

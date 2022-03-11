import os
import time
import json
import ipaddress
import re
import pymysql
import sys
#import charts

from flask import Flask,request,redirect,Response,make_response,jsonify,render_template,session,send_file

app = Flask(__name__)

with open('db.conf', 'r') as f:
    db_settings = json.loads(f.read())

with open('node.conf', 'r') as f:
    nodes = f.read().split()

@app.route('/',methods=['POST'])
def check():
    #if type(ipaddress.ip_address(request.form["cltip"])).__name__ != 'IPv4Address':
    #    return 'error'
    data = json.loads(request.get_data())
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
    except Exception as ex:
        print(ex, file=sys.stderr)
        os.system('ssh root@' + nownode + ' "bash judgescript/clear.sh ' + str(labdata['checkonhost']) + '; rm -r judgescript"')
    if not labdata['checkonhost']:
        nodes.append(nownode)
    return getans

@app.route('/alive',methods=['GET'])
def alive():
    return "true"

@app.route('/serverlist',methods=['GET'])
def serverlist():
    return json.dumps(nodes)

@app.route('/getdbscore/<path:path>',methods=['GET'])
def getdbscorepath(path):
    showresult = False
    if path == 'result':
        showresult = True

    # 建立Connection物件
    conn = pymysql.connect(**db_settings)
    cursor = conn.cursor()
    if showresult:
        cursor.execute("SELECT labid, studentId, score, result FROM score")
    else:
        cursor.execute("SELECT labid, studentId, score FROM score")

    result_set = cursor.fetchall()
    allscore = {}
    for a in result_set:
        if not allscore.__contains__(a[0]):
            allscore[a[0]] = {}
        if not allscore[a[0]].__contains__(a[1]):
            allscore[a[0]][a[1]] = {'score':a[2]}
            if showresult:
                allscore[a[0]][a[1]]['result'] = json.loads(a[3])
        elif allscore[a[0]][a[1]]['score'] < a[2]:
            allscore[a[0]][a[1]] = {'score':a[2]}
            if showresult:
                allscore[a[0]][a[1]]['result'] = json.loads(a[3])
    return json.dumps(allscore)

@app.route('/getdbscore',methods=['GET'])
def getdbscore():
    return getdbscorepath('')

@app.errorhandler(404)
def page_not_found(e):
    return_result = {'code': 404, 'Success': False,
                     "Message": "The website is not available currently"}
    return jsonify(return_result), 404


@app.errorhandler(403)
def forbidden(e):
    return_result = {'code': 403, 'Success': False,
                     "Message": "The website is not available currently"}
    return jsonify(return_result), 403


if __name__ == "__main__":
    app.run(host="::",port=80)



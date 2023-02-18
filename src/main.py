import os
import sys
import io
import time
import json
import yaml
import ipaddress
import re
import sys
import uuid
import requests
import threading
import shutil
import subprocess
import importlib
import zipfile
import usersetting

#import charts
from paramiko import SSHClient, SFTPClient, AutoAddPolicy
from flask import Flask,request,redirect,Response,make_response,jsonify,render_template,session,send_file,send_from_directory

app = Flask(__name__)

hostusing = False

judgingusers = []

stoping = False

lock = threading.Lock()

adduserlock = threading.Lock()

with open('config.yaml', 'r') as f:
    config = yaml.load(f, Loader=yaml.FullLoader)
    config['maxworkerslen'] = len(config['workers'])

@app.route('/', methods=['GET'])
def help():
    return ""

@app.route('/stop', methods=['GET'])
def stop():
    stoping = True
    return json.dumps(len(config['workers']) >= config['maxworkerslen'] and not hostusing and len(judgingusers) == 0)

@app.route('/judge',methods=['POST'])
def judge():
    if stoping:
        return json.dumps({'alive':False})
    data = json.loads(request.get_data())
    lock.acquire()
    if data['username'] in judgingusers:
        lock.release()
        return json.dumps({'alive':False})
    judgingusers.append(data['username'])
    lock.release()
    with open(f'judge/labs/{data["labId"]}/config.yaml', 'r') as f:
        labdata = yaml.load(f, Loader=yaml.FullLoader)
    if labdata['checkonhost']:
        lock.acquire()
        while hostusing:
            lock.release()
            time.sleep(0.1)
            lock.acquire()
        hostusing = True
        data['workerhost'] = "localhost"
        lock.release()
    else:
        lock.acquire()
        while len(config['workers']) <= 0:
            lock.release()
            time.sleep(0.1)
            lock.acquire()
        data['workerhost'] = config['workers'].pop(0)
        lock.release()
    data['taskId'] = str(uuid.uuid4())

    try:
        try:
            subprocess.run(f'ansible-galaxy collection install -r judge/labs/{data["labId"]}/requirements.yml', shell=True)
            subprocess.run(f'ansible-galaxy role install -r judge/labs/{data["labId"]}/requirements.ym', shell=True)
            process = subprocess.run(f"ansible-playbook judge/setup.yml -e '{json.dumps(data)}'", shell=True, timeout=labdata['timeout'])
            if process.returncode < 0 or process.returncode == 143 or process.returncode == 137:
                raise Exception('bad return code')
        except:
            try:
                subprocess.run(f"ansible-playbook judge/clearsetup.yml -e '{json.dumps(data)}'", shell=True, timeout=labdata['timeout'])
            except: 
                pass
            return json.dumps({'alive':False})

        with open(f'/tmp/{data["taskId"]}/result', 'r') as f:
            result = f.read()
        with open(f'/tmp/{data["taskId"]}/stdout', 'r') as f:
            stdout = f.read()
        with open(f'/tmp/{data["taskId"]}/stderr', 'r') as f:
            stderr = f.read()
    finally:
        shutil.rmtree(f'/tmp/{data["taskId"]}', ignore_errors=True)

        lock.acquire()
        if labdata['checkonhost']:
            hostusing = False
        else:
            config['workers'].append(data['workerhost'])
        judgingusers.remove(data['username'])
        lock.release()
    return json.dumps({'alive':True, 'results':json.loads(result), 'stdout':stdout, 'stderr':stderr})

@app.route('/canjudge',methods=['POST'])
def canjudge():
    if stoping:
        return json.dumps(False)
    data = json.loads(request.get_data())
    lock.acquire()
    result = not (data['username'] in judgingusers)
    lock.release()
    return json.dumps(result)

@app.route('/getLabs',methods=['GET'])
def getLabs():
    if stoping:
        return json.dumps([])
    result = []
    for a in os.listdir('judge/labs'):
        data = json.loads(getLab(a))
        if data is not None:
            result.appent(data)

    return json.dumps(result)

@app.route('/getLab/<string:labId>',methods=['GET'])
def getLab(path):
    if stoping:
        return json.dumps(None)
    labId = labId.split('/')[0]
    result = None
    if os.path.isdir(f'judge/labs/{labId}') and os.path.isfile(f'judge/labs/{labId}/config.yaml'):
        with open(f'judge/labs/{labId}/config.yaml', 'r') as f:
            try:
                labconfig = yaml.load(f, Loader=yl.FullLoader)
            except yaml.scanner.ScannerError:
                labconfig = {}
        if 'promissions' not in labconfig:
            labconfig['promissions'] = []
        if 'frontendvariable' not in labconfig:
            labconfig['frontendvariable'] = []
        result = {'id':path, 'contents':labconfig['frontendvariable'], 'promissions':labconfig['promissions'], 'deadlines':labconfig['deadlines']}
    return json.dumps(result)

@app.route('/alive',methods=['GET'])
def alive():
    if stoping:
        return "false"
    return "true"

@app.route('/workerlist',methods=['GET'])
def serverlist():
    return json.dumps(config['workers'])

@app.route('/getuserdata',methods=['POST'])
def getuserdata():
    if stoping:
        return ""
    data = request.get_json()
    session = requests.Session()
    session.post(f"{config['judegbackendhost']}/user/login", json={'username':config['adminuser'],'password':config['adminpassword']})
    r = session.post(f"{config['judegbackendhost']}/user/userdata", json=data)
    return r.test

@app.route('/getalluserdata',methods=['GET'])
def getalluserdata():
    if stoping:
        return ""
    session = requests.Session()
    session.post(f"{config['judegbackendhost']}/user/login", json={'username':config['adminuser'],'password':config['adminpassword']})
    r = session.get(f"{config['judegbackendhost']}/user/alluserdata")
    return r.test

@app.route('/download/<string:labId>/<path:path>',methods=['GET'])
def download(labId, path):
    if stoping:
        return ""
    return send_from_directory(f'judge/labs/{labId}/download/', path, as_attachment=True)

@app.route('/download/userconfig',methods=['POST'])
def userconfig():
    if stoping:
        return ""
    data = request.get_json()
    zipname = str(uuid.uuid4())

    sendfile = io.BytesIO()
    with zipfile.ZipFile(sendfile, 'w') as myzip:
        with SSHClient() as ssh:
            ssh.load_system_host_keys()
            ssh.set_missing_host_key_policy(AutoAddPolicy())
            ssh.connect(hostname=config['wireguard']['host'])
            with SFTPClient.from_transport(ssh.get_transport()) as sftp:
                for tunnel in config["wireguard"]["tunnels"]:
                    with sftp.file(f'/etc/wireguard/{tunnel["client"]["dir"]}/{data["username"]}.conf','r') as f:
                        myzip.writestr(f'{tunnel["client"]["configname"]}.conf', f.read())        

        myzip.writestr('authorized_keys', '\n'.join(config['workerspubkeys']))

        for nowconfigfile in usersetting.userconfig(data):
            with nowconfigfile['file'] as f:
                myzip.writestr(os.path.basename(nowconfigfile['filename']), f.read())
    sendfile.seek(0)
    return Response(sendfile.getvalue(), mimetype='application/zip', headers={'Content-Disposition': 'attachment;filename=userconfig.zip'})

@app.route('/download/<string:labId>/description',methods=['GET'])
def description(labId):
    if stoping:
        return ""
    with open(f'judge/labs/{data["labId"]}/config.yaml', 'r') as f:
        labdata = yaml.load(f, Loader=yaml.FullLoader)
    return send_from_directory(f'judge/labs/{labId}/', labdata['description'], as_attachment=True)

@app.route('/builduser',methods=['POST'])
def onbuilduser():
    if stoping:
        return ""
    adduserlock.acquire()
    try:
        data = request.get_json()
        subprocess.run(f"ansible-galaxy collection install -r builduser/requirements.yml -f", shell=True)
        subprocess.run(f"ansible-galaxy role install -r builduser/requirements.yml -f", shell=True)
        subprocess.run(f"ansible-playbook builduser/setup.yml -e '{json.dumps(data)}'", shell=True)
        usersetting.builduser(data)
    finally:
        adduserlock.release()
    return "true"

@app.route('/getresult',methods=['POST'])
def getresult():
    if stoping:
        return json.dumps(None)
    data = request.get_json()
    session = requests.Session()
    session.post(f"{config['judegbackendhost']}/user/login", json={'username':config['adminuser'],'password':config['adminpassword']})
    r = session.post(f"{config['judegbackendhost']}/score", json=data)
    result_set = json.loads(r.text)
    allscore = {}
    for a in result_set:
        nowdata = {'score':a['score']}
        if data.get('showresult', False):
            nowdata['result'] = a['result']
        if a['labId'] not in allscore:
            allscore[a['labId']] = {}

        if data.get('max', False):
            if a['username'] not in allscore[a['labId']]:
                allscore[a['labId']][a['username']] = []
            allscore[a['labId']][a['username']].append(nowdata)
        else:
            if a['username'] not in allscore[a['labId']] or allscore[a['labId']][a['username']]['score'] < a['score']:
                allscore[a['labId']][a['username']] = nowdata
    return json.dumps(allscore)



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
    app.run(host="::",port=int(config['ListenPort']))



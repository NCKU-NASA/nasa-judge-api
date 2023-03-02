import os
import sys
import json
import yaml
import uuid
import shutil
import threading
import subprocess
import docker

import flask

import conf
import utils.backend as backend

app = flask.Blueprint('score', __name__)
client = docker.from_env()

@app.route('', methods=['GET'])
@app.route('/', methods=['GET'])
def help():
    return """
Usage: curl <host>/score/<api> -H 'Content-Type: application/json'

POST:
    get                         Get score and result from backend.
                                input:
                                    json:
                                        labId: labId you want to search
                                        username: username you want to search
                                        usedeadline: calc deadline score
                                        showresult: show all result
                                        max: show max score only
                                return: json
    canjudge                    Check is user can judge?
                                input:
                                    json:
                                        username: user name.
                                return: bool
    judge                       Judging.
                                input:
                                    json:
                                        labId: lab id that need judge.
                                        username: judge user.
                                        ipindex: user ipindex
                                        data: list. Same as the frontendvariable in config.yaml from <labId> dir.
                                return:
                                    json:
                                        alive: Is judge alive?
                                        result: Judge result.
                                        stdout: All stdout in judge.
                                        stderr: All stderr in judge.
"""

lock = threading.Lock()
@app.route('/get',methods=['POST'])
def getresult():
    if conf.stoping:
        return json.dumps(None)
    data = flask.request.get_json()
    r = backend.post("score", json=data)
    result_set = json.loads(r.text)
    allscore = {}
    for a in result_set:
        nowdata = {'score':a['score']}
        if data.get('showresult', False):
            nowdata['result'] = a['result']
        if a['labId'] not in allscore:
            allscore[a['labId']] = {}

        if not data.get('max', True):
            if a['username'] not in allscore[a['labId']]:
                allscore[a['labId']][a['username']] = []
            allscore[a['labId']][a['username']].append(nowdata)
        else:
            if a['username'] not in allscore[a['labId']] or allscore[a['labId']][a['username']]['score'] < a['score']:
                allscore[a['labId']][a['username']] = nowdata
    return json.dumps(allscore)


@app.route('/judge',methods=['POST'])
def judge():
    if conf.stoping:
        return json.dumps({'alive':False})
    data = json.loads(flask.request.get_data())
    lock.acquire()
    if data['username'] in conf.judgingusers:
        lock.release()
        return json.dumps({'alive':False})
    conf.judgingusers.append(data['username'])
    lock.release()
    try:
        with open(f'judge/labs/{data["labId"]}/config.yaml', 'r') as f:
            labdata = yaml.load(f, Loader=yaml.FullLoader)
        data['taskId'] = str(uuid.uuid4())
        lock.acquire()
        if labdata['checkonhost']:
            while conf.hostusing:
                lock.release()
                time.sleep(0.1)
                lock.acquire()
            conf.hostusing = True
            data['workerhost'] = "localhost"
        elif labdata['workerusedocker']:
            if len(client.images.list(name=data["labId"].lower())) == 0:
                with open(os.path.join(os.path.expanduser('~'), '.ssh/id_rsa'), 'r') as f:
                    sshkey = f.read()
                client.images.build(path=f'judge/labs/{data["labId"]}', tag=data["labId"].lower(), buildargs={'ssh_prv_key':sshkey}, nocache=True)
            dockerargs = {'image':data["labId"].lower(), 'hostname':data['taskId'].lower(), 'name':data['taskId'].lower(), 'stdin_open':True, 'detach':True)
            if 'dockerargs' in labdata:
                for a in labdata['dockerargs']:
                    dockerargs[a] = labdata['dockerargs'][a]
            dockerworker = client.containers.run(**dockerargs)
            data['workerhost'] = data['taskId']
        else:
            while len(conf.config['workers']) <= 0:
                lock.release()
                time.sleep(0.1)
                lock.acquire()
            data['workerhost'] = conf.config['workers'].pop(0)
        lock.release()

        try:
            try:
                subprocess.run(['ansible-galaxy', 'collection', 'install', '-r', 'judge/requirements.yml'])
                subprocess.run(['ansible-galaxy', 'role', 'install', '-r', 'judge/requirements.yml'])
                if labdata['ansiblejudgescript']:
                    subprocess.run(['ansible-galaxy', 'collection', 'install', '-r', f'judge/labs/{data["labId"]}/requirements.yml'])
                    subprocess.run(['ansible-galaxy', 'role', 'install', '-r', f'judge/labs/{data["labId"]}/requirements.yml'])
                process = subprocess.run(['ansible-playbook', 'judge/setup.yml', '-e', json.dumps(data)], timeout=labdata['timeout'])
                if process.returncode < 0 or process.returncode == 143 or process.returncode == 137:
                    raise Exception('bad return code')
            except:
                try:
                    subprocess.run(['ansible-playbook', 'judge/clearsetup.yml', '-e', json.dumps(data)], timeout=labdata['timeout'])
                except: 
                    pass
                return json.dumps({'alive':False})
            
            if os.path.isfile(f'/tmp/{data["taskId"]}/result'):
                with open(f'/tmp/{data["taskId"]}/result', 'r') as f:
                    result = f.read()
            else:
                result = ""
            if os.path.isfile(f'/tmp/{data["taskId"]}/stdout'):
                with open(f'/tmp/{data["taskId"]}/stdout', 'r') as f:
                    stdout = f.read()
            else:
                stdout = ""
            if os.path.isfile(f'/tmp/{data["taskId"]}/stderr'):
                with open(f'/tmp/{data["taskId"]}/stderr', 'r') as f:
                    stderr = f.read()
            else:
                stderr = ""
        finally:
            shutil.rmtree(f'/tmp/{data["taskId"]}', ignore_errors=True)

            lock.acquire()
            if labdata['checkonhost']:
                conf.hostusing = False
            elif labdata['workerusedocker']:
                dockerworker.stop()
                dockerworker.remove(force=True)
            else:
                conf.config['workers'].append(data['workerhost'])
            lock.release()
    finally:
        lock.acquire()
        conf.judgingusers.remove(data['username'])
        lock.release()
    return json.dumps({'alive':True, 'results':json.loads(result), 'stdout':stdout, 'stderr':stderr})


@app.route('/canjudge',methods=['POST'])
def canjudge():
    if conf.stoping:
        return json.dumps(False)
    data = json.loads(flask.request.get_data())
    lock.acquire()
    result = not (data['username'] in conf.judgingusers)
    lock.release()
    return json.dumps(result)




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

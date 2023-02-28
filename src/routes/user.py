import io
import os
import json
import uuid
import threading
import subprocess
import zipfile

from paramiko import SSHClient, SFTPClient, AutoAddPolicy

import flask

import conf
import utils.backend as backend
import usersetting

app = flask.Blueprint('user', __name__)

adduserlock = threading.Lock()

@app.route('', methods=['GET'])
@app.route('/', methods=['GET'])
def help():
    return """
Usage: <host>/user/<api>

GET:
    getdata                     Get all user data from backend.
                                return: list
POST:
    getdata                     Get user data from backend.
                                input:
                                    json:
                                        username: user name
                                        or
                                        studentId: user studentId
                                        or
                                        email: user email
                                        or
                                        ipindex: user ipindex
                                return:
                                    json:
                                        username: user name
                                        password: user password
                                        studentId: user studentId
                                        email: user email
                                        ipindex: user ipindex

    build                       Build user config.
                                input:
                                    json:
                                        username: user name
                                        password: user password
                                        studentId: user studentId
                                        email: user email
                                        ipindex: user ipindex
                                return: bool
    changename                  Change user name.
                                input:
                                    json:
                                        username: new user name
                                        password: user password
                                        studentId: user studentId
                                        email: user email
                                        ipindex: user ipindex
                                        oldusername: old user name
                                return: bool
    config                      Download user config.
                                input:
                                    json:
                                        username: user name
                                        password: user password
                                        studentId: user studentId
                                        email: user email
                                        ipindex: user ipindex
                                return: file
"""

@app.route('/getdata',methods=['GET'])
def getalldata():
    if conf.stoping:
        return ""
    r = backend.get("user/alluserdata")
    return r.text

@app.route('/getdata',methods=['POST'])
def getdata():
    if conf.stoping:
        return ""
    data = flask.request.get_json()
    r = backend.post("user/userdata", json=data)
    return r.text

@app.route('/build',methods=['POST'])
def onbuilduser():
    if conf.stoping:
        return ""
    conf.buildingusercount += 1
    adduserlock.acquire()
    try:
        data = flask.request.get_json()
        subprocess.run(['ansible-galaxy', 'collection', 'install', '-r', 'builduser/requirements.yml'])
        subprocess.run(['ansible-galaxy', 'role', 'install', '-r', 'builduser/requirements.yml'])
        subprocess.run(['ansible-playbook', 'builduser/setup.yml', '-e', json.dumps(data)])
        usersetting.builduser(data)
    finally:
        adduserlock.release()
        conf.buildingusercount -= 1
    return "true"

@app.route('/changename',methods=['POST'])
def onchangename():
    if conf.stoping:
        return ""
    adduserlock.acquire()
    try:
        data = flask.request.get_json()
        subprocess.run(['ansible-galaxy', 'collection', 'install', '-r', 'changename/requirements.yml'])
        subprocess.run(['ansible-galaxy', 'role', 'install', '-r', 'changename/requirements.yml'])
        subprocess.run(['ansible-playbook', 'changename/setup.yml', '-e', json.dumps(data)])
    finally:
        adduserlock.release()
    return "true"


@app.route('/config',methods=['POST'])
def userconfig():
    if conf.stoping:
        return ""
    data = flask.request.get_json()
    zipname = str(uuid.uuid4())

    try:
        sendfile = io.BytesIO()
        with zipfile.ZipFile(sendfile, 'w') as myzip:
            with SSHClient() as ssh:
                ssh.load_system_host_keys()
                ssh.set_missing_host_key_policy(AutoAddPolicy())
                ssh.connect(hostname=conf.config['wireguard']['host'])
                with SFTPClient.from_transport(ssh.get_transport()) as sftp:
                    for tunnel in conf.config["wireguard"]["tunnels"]:
                        with sftp.file(f'/etc/wireguard/{tunnel["client"]["dir"]}/{data["username"]}.conf','r') as f:
                            myzip.writestr(f'{tunnel["client"]["configname"]}.conf', f.read())        

            myzip.writestr('authorized_keys', '\n'.join(conf.config['workerspubkeys']) + '\n')

            for nowconfigfile in usersetting.userconfig(data):
                with nowconfigfile['file'] as f:
                    myzip.writestr(os.path.basename(nowconfigfile['filename']), f.read())
        sendfile.seek(0)
        return flask.Response(sendfile.getvalue(), mimetype='application/zip', headers={'Content-Disposition': 'attachment;filename=userconfig.zip'})
    except:
        return_result = {'code': 404, 'Success': False,
                         "Message": "The website is not available currently"}
        return flask.jsonify(return_result), 404
@app.errorhandler(404)
def page_not_found(e):
    return_result = {'code': 404, 'Success': False,
                     "Message": "The website is not available currently"}
    return flask.jsonify(return_result), 404


@app.errorhandler(403)
def forbidden(e):
    return_result = {'code': 403, 'Success': False,
                     "Message": "The website is not available currently"}
    return flask.jsonify(return_result), 403

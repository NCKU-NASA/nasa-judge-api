import os
import time
import json
import ipaddress
import re

from flask import Flask,request,redirect,Response,make_response,jsonify,render_template,session,send_file

app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24)



dir = "web/"


with open('node.conf', 'r') as f:
    nodes = f.read().split()

@app.route('/',methods=['GET'])
def host():
    if session.get('username') == None:
        data = ""
        with open(dir + "index.html", "r", encoding='UTF-8') as f:
            data = f.read()
        resp = make_response(data)
        return resp
    else:
        resp = render_template('login.html', username=session['username'])
        return resp
        
@app.route('/',methods=['POST'])
def logout():
    session.clear()
    return host()

@app.route('/login',methods=['POST','GET'])
def login():
    if request.method == 'POST':
        session['username'] = re.sub(r'[^a-zA-Z0-9]', '', request.form["username"])
        if not os.path.exists('/etc/wireguard/client/' + session['username'] + '.conf'):
            session.clear()
            return 'fail'
        resp = render_template('login.html', username=session["username"])
        return resp
    elif request.method == 'GET':
        return host()

@app.route('/downloadlab',methods=['GET'])
def lab():
    session['username'] = re.sub(r'[^a-zA-Z0-9]', '', session["username"])
    if not os.path.exists('/etc/wireguard/client/' + session['username'] + '.conf'):
        session.clear()
        return 'fail'
    return send_file('lab.pdf', as_attachment=True)

@app.route('/downloadwiregaurd',methods=['GET'])
def wiregaurd():
    session['username'] = re.sub(r'[^a-zA-Z0-9]', '', session["username"])
    if not os.path.exists('/etc/wireguard/client/' + session['username'] + '.conf'):
        session.clear()
        return 'fail'
    return send_file('/etc/wireguard/client/' + session['username'] + '.conf', as_attachment=True)

@app.route('/check',methods=['POST'])
def check():
    data = ""
    try:
        session['username'] = re.sub(r'[^a-zA-Z0-9]', '', session["username"])
        if not os.path.exists('/etc/wireguard/client/' + session['username'] + '.conf'):
            session.clear()
            return 'fail'
        if type(ipaddress.ip_address(request.form["cltip"])).__name__ != 'IPv4Address':
            return 'error'
    except:
        return 'error'

    while len(nodes) <= 0:
        time.sleep(0.1)
    nownode = nodes.pop()
    try:
        os.system('> ~/.ssh/known_hosts')
        clientip = os.popen('grep -B 1 -A 3 "# ' + session.get('username') + '" /etc/wireguard/server.conf | grep -oP \'(?<=AllowedIPs\s=\s)\d+(\.\d+){3}\' | tail -n 1').read().strip()
        ca = request.files['ca']
        ca.save(os.path.join('/tmp', 'ca.crt'))
        os.system('scp ' + os.path.join('/tmp', 'ca.crt') + ' root@' + nownode + ':ca.crt')
        os.system('ssh root@' + nownode + ' rm -r judgescript')
        os.system('scp -r judgescript root@' + nownode + ':judgescript')
        os.system('ssh root@' + nownode + ' mv ca.crt judgescript/ca.crt')
        getans = os.popen('ssh root@' + nownode + ' "cd judgescript/; python3 judge.py ' + session.get('username') + ' ' + clientip + ' ' + request.form["cltip"] + '"').read().strip()
        os.system('ssh root@' + nownode + ' rm -r judgescript')
    except:
        os.system('ssh root@' + nownode + ' bash judgescript/clear.sh')
        os.system('ssh root@' + nownode + ' rm -r judgescript')
    nodes.append(nownode)
    try:
        getansjson = json.loads(getans)
        keys=list(getansjson.keys())
        allcont = 0
        getcont = 0
        for key in keys:
            allcont += len(getansjson[key])
            for i in range(len(getansjson[key])):
                if getansjson[key][i]['ans']:
                    getcont+=1
#        getans = json.loads(getans)
#        with open(os.path.join('/tmp', 'ans.json'), 'w') as f:
#            f.write(getans)
#        return render_template('check.html', ans=os.popen('cat /tmp/ans.json | jq').read())
        data = ""
        with open(dir + "check.html", "r", encoding='UTF-8') as f:
            data = f.read()
        data = data.replace('{{ ans }}', getans).replace('{{ score }}', str(getcont) + '/' + str(allcont))
        resp = make_response(data)
        return resp
#        return render_template('check.html', ans=getans)
#        return '<code>' + os.popen('cat /tmp/ans.json | jq').read() + '</code>'
        #return getans
    except:
        return 'error'




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



import os
import time
import json
import ipaddress
import re

from flask import Flask,request,redirect,Response,make_response,jsonify,render_template,session,send_file

app = Flask(__name__)

with open('node.conf', 'r') as f:
    nodes = f.read().split()

@app.route('/',methods=['POST'])
def check():
    #if type(ipaddress.ip_address(request.form["cltip"])).__name__ != 'IPv4Address':
    #    return 'error'
    data = json.loads(request.get_data())
    while len(nodes) <= 0:
        time.sleep(0.1)
    nownode = nodes.pop(0)
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
    return getans

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



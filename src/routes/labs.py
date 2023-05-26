import json
import yaml
import os
import flask

import conf

app = flask.Blueprint('labs', __name__)


@app.route('', methods=['GET'])
@app.route('/', methods=['GET'])
def help():
    return """
Usage: curl <host>/labs/<api> -H 'Content-Type: application/json'

GET:
    getdata                     Get all of labs info.
                                return: list
    <labId>/getdata             Get lab info which you select.
                                return: dict
    <labId>/file/<path>         Download the file that is documented in the frontendvariable in config.yaml from <labId> dir.
                                return: file
    <labId>/file/description    Download the description file of <labId>.
                                return: file
"""

@app.route('/getdata',methods=['GET'])
def getLabs():
    if conf.stoping:
        return json.dumps([])
    result = []
    for a in sorted(os.listdir('judge/labs'), reverse=True):
        data = json.loads(getLab(a))
        if data is not None:
            result.append(data)

    return json.dumps(result)

@app.route('/<string:labId>/getdata',methods=['GET'])
def getLab(labId):
    if conf.stoping:
        return json.dumps(None)
    labId = labId.split('/')[0]
    result = None
    if os.path.isdir(f'judge/labs/{labId}') and os.path.isfile(f'judge/labs/{labId}/config.yaml'):
        with open(f'judge/labs/{labId}/config.yaml', 'r') as f:
            try:
                labconfig = yaml.load(f, Loader=yaml.FullLoader)
            except yaml.scanner.ScannerError:
                labconfig = {}
        if 'promissions' not in labconfig:
            labconfig['promissions'] = []
        if 'frontendvariable' not in labconfig:
            labconfig['frontendvariable'] = []
        if 'deadlines' not in labconfig:
            labconfig['deadlines'] = []
        if 'checkpoints' not in labconfig:
            labconfig['checkpoints'] = {}
        result = {'id':labId, 'contents':labconfig['frontendvariable'], 'checkpoints':labconfig['checkpoints'], 'promissions':labconfig['promissions'], 'deadlines':labconfig['deadlines']}
    return json.dumps(result)

@app.route('/<string:labId>/file/<path:path>',methods=['GET'])
def download(labId, path):
    if conf.stoping:
        return ""
    if os.path.isfile(f'judge/labs/{labId}/download/{path}'):
        return flask.send_from_directory(f'judge/labs/{labId}/download/', path, as_attachment=True)
    else:
        return_result = {'code': 404, 'Success': False,
                         "Message": "The website is not available currently"}
        return flask.jsonify(return_result), 404

@app.route('/<string:labId>/file/description',methods=['GET'])
def description(labId):
    if conf.stoping:
        return ""
    with open(f'judge/labs/{labId}/config.yaml', 'r') as f:
        labdata = yaml.load(f, Loader=yaml.FullLoader)
    
    if os.path.isfile(f'judge/labs/{labId}/{labdata["description"]}'):
        return flask.send_from_directory(f'judge/labs/{labId}/', labdata['description'], as_attachment=True)
    else:
        return_result = {'code': 404, 'Success': False,
                         "Message": "The website is not available currently"}
        return flask.jsonify(return_result), 404

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

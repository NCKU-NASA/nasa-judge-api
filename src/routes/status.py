import json

import flask

import conf

app = flask.Blueprint('status', __name__)


@app.route('', methods=['GET'])
@app.route('/', methods=['GET'])
def help():
    return """
Usage: <host>/status/<api>

GET:
    stop                        Run stop and wait until result become true before stop this service.
                                return: bool
    start                       Start after run stop.
                                return: bool
    alive                       Check service alive.
                                return: bool
    workerlist                  Get all of workers which is idle.
                                return: list
"""

@app.route('/stop', methods=['GET'])
def stop():
    conf.stoping = True
    return json.dumps(len(conf.config['workers']) >= conf.maxworkerslen and not conf.hostusing and len(conf.judgingusers) == 0 and conf.buildingusercount == 0)

@app.route('/start', methods=['GET'])
def start():
    conf.stoping = False

@app.route('/alive',methods=['GET'])
def alive():
    if conf.stoping:
        return "false"
    return "true"

@app.route('/workerlist',methods=['GET'])
def serverlist():
    return json.dumps(conf.config['workers'])
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

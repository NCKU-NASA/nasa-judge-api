import flask

import conf
import routes.status
import routes.labs
import routes.user
import routes.score


app = flask.Flask(__name__)

app.register_blueprint(routes.status.app, url_prefix='/status')
app.register_blueprint(routes.labs.app, url_prefix='/labs')
app.register_blueprint(routes.user.app, url_prefix='/user')
app.register_blueprint(routes.score.app, url_prefix='/score')

@app.route('/', methods=['GET'])
def help():
    return """
Usage: curl <host>/<api> -H 'Content-Type: application/json'

GET:
    pubkey                      Download ssh public key that is documented in the workerspubkeys in config.yaml.
                                return: text

routes:
    status                      Show api status.
    labs                        Show labs info and labs files.
    user                        Show and set user.
    score                       Show score or judge.
"""

@app.route('/pubkey',methods=['GET'])
def pubkey():
    if conf.stoping:
        return ""
    try:
        return '\n'.join(conf.config['workerspubkeys']) + '\n'
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


if __name__ == "__main__":
    app.run(host="::",port=int(conf.config['ListenPort']))



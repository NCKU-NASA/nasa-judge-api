import requests
import conf

def session():
    session = requests.Session()
    session.post(f"{conf.config['judegbackendhost']}/user/login", json={'username':conf.config['adminuser'],'password':conf.config['adminpassword']})
    return session

def get(url, *args, **kwargs):
    return session().get(f"{conf.config['judegbackendhost']}/{url}", *args, **kwargs)

def post(url, *args, **kwargs):
    return session().post(f"{conf.config['judegbackendhost']}/{url}", *args, **kwargs)

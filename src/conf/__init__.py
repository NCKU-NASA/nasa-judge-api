import yaml

hostusing = False

judgingusers = {}

buildingusercount = 0

stoping = False

with open('config.yaml', 'r') as f:
    config = yaml.load(f, Loader=yaml.FullLoader)
    maxworkerslen = len(config['workers'])

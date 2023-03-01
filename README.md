# nasa-judge-api
NCKU NASA judge api service

- [Install](#Install)
- [Remove](#Remove)
- [Api](#Api)
- [How to write a Lab check code](#how-to-write-a-lab-check-code)
## Install
1. clone this repo and cd into nasa-judge-api.

```bash
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
```

2. Set `config.yaml` for install

3. run `install.sh`

```bash
bash install.sh
```

4. Set `/etc/nasajudgeapi/config.yaml` for install

5. Start it with systemd.
``` bash
systemctl start nasajudgeapi.service
```

6. Before restart or stop, please use `status/stop` api first and wait it be `true`.
``` bash
while [ "$(curl 127.0.0.1/status/stop)" == "false" ]
do
    sleep 1
done
systemctl stop nasajudgeapi.service
```

## Remove
### TODO

## Api
Use `/` to get help.
``` bash
curl 127.0.0.1
```

```
Usage: curl <host>/<api> -H 'Content-Type: application/json'

GET:
    pubkey                      Download ssh public key that is documented in the workerspubkeys in config.yaml.
                                return: text

routes:
    status                      Show api status.
    labs                        Show labs info and labs files.
    user                        Show and set user.
    score                       Show score or judge.
```

## How to write a Lab check code
cd into `/etc/nasajudgeapi/judge/labs` and make labId dir.

```bash
cd /etc/nasajudgeapi/judge/labs
mkdir <labid>
cd <labid>
```
### script mode
1. Set and write your `config.yaml` for lab. In `script mode` here is example.
```yaml
promissions:   # It mean this lab is for which groups.
- guest
- student
- admin
deadlines:     # Set your deadlines and the score scale before deadline.
- time: "2023-03-09 23:59:59"
  score: 1
checkonhost: false         # use worker or host
workerusedocker: false     # worker using docker? (TODO)
ansiblejudgescript: false  # for "script mode" please set "false"
timeout: 120               # judge timeout
network: 10.100.100.0/24   # network for student machine 
package:                   # package for judge on worker
- curl
- dnsutils
- git
- jq
- sshpass
- wget
  
description: "description.pdf"  # description path

init: 
  command: "bash {{ taskpath }}.sh" # execution init script command
  scriptname: "init"                # init script name (optional)
  become: false                     # sudo to root?

clear: 
  command: "bash {{ taskpath }}.sh" # execution init script command
  become: false                     # sudo to root?

checkpoints:                        # checkpoint infos
  <group1>:                         # checkgroup (please make a checkgroup dir in lab dir)
  - message: linux can ping 8.8.8.8
    scriptname: "0"                 # checkpoint script name (optional)
    command: "bash {{ taskpath }}.sh '{{ wanip }}' '{{ username }}'" # execution checkpoint script command
    become: false                   # sudo to root?
    weight: 50                      # weight of this checkpoint
    check: {}                       # check condition
  - message: sudo can no password
    command: "bash {{ taskpath }}.sh '{{ wanip }}' '{{ username }}'"
    become: false
    weight: 50
    check: 
      <group1>:
      - 0

frontendvariable:                   # variable for frontend
- type: download                    # A file need download at frontend
  name: <filename(no space)>
  useusername: false                # different for every user (optional)
- type: input                       # A input data for judge
  name: <varable name(no space)>    # this name will be a global variable name in ansible(see checkpoints.<group1>[0].command).
- type: upload                      # A upload file for judge
  name: <filename(no space)>        # file will save at workdir. use it with name (cat <filename(no space)>)
```

2. For judge script, on check fail please return with `return code 1`, on check success please return with `return code 0`. Show output and error at `stdout` and `stderr`
``` bash
#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>" 1>&2
    exit 1
fi

> judgeerrlog
> judgelog

shellreturn()
{
    cat judgelog
    cat judgeerrlog 1>&2
    exit $1
}

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ping 8.8.8.8 -c 1 -W 1 2>>judgeerrlog | tee -a judgelog | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    shellreturn 1
fi

shellreturn 0
```

3. This is dir tree
```
.
├── clear.sh
├── config.yaml
├── description.pdf
├── <group1>
│   ├── 0.sh
│   └── 1.sh
└── init.sh
```

### ansible mode
1. Set and write your `config.yaml` for lab. In `script mode` here is example.
```yaml
promissions:   # It mean this lab is for which groups.
- guest
- student
- admin
deadlines:     # Set your deadlines and the score scale before deadline.
- time: "2023-03-09 23:59:59"
  score: 1
checkonhost: false         # use worker or host
workerusedocker: false     # worker using docker? (TODO)
ansiblejudgescript: true   # for "ansible mode" please set "true"
timeout: 300               # judge timeout
network: 10.187.96.0/20    # network for student machine 
package:                   # package for judge on worker
- curl
- dnsutils
- git
- jq
- sshpass
- wget
- ansible
  
description: "description.pdf"  # description path

init: 
  scriptname: "init"                # init script name (without .yml) (optional)

clear: {}

checkpoints:                        # checkpoint infos
  <group1>:                         # checkgroup (please make a checkgroup dir in lab dir)
  - message: linux can ping 8.8.8.8
    scriptname: "0"                 # checkpoint script name (without .yml) (optional)
    weight: 50                      # weight of this checkpoint
    check: {}                       # check condition
  - message: sudo can no password
    weight: 50
    check: 
      <group1>:
      - 0

frontendvariable:                   # variable for frontend
- type: download                    # A file need download at frontend
  name: <filename(no space)>
  useusername: false                # different for every user (optional)
- type: input                       # A input data for judge
  name: <varable name(no space)>    # this name will be a global variable name in ansible(use it with {{ <varable name(no space)> }}).
- type: upload                      # A upload file for judge
  name: <filename(no space)>        # file will save at "/tmp/{{ taskId }}/workspace/<filename(no space)>" at worker(remote).
```

2. Write requirements.yml for install rule in judge
``` yaml
collections:
  - name: ansible.netcommon

roles: []
```

3. For judge script, on check fail please `fail this judge task`, on check success please `don't fail this judge task`. Save output at `/tmp/{{ taskId }}/stdout`. Save error at `/tmp/{{ taskId }}/stderr` 
``` yaml
- name: Ping Test
  command: "ping {{ wanip }} -c 1 -w 1"
  register: pingresult
  ignore_errors: true

- name: Get stdout and stderr
  blockinfile:
    path: "/tmp/{{ taskId }}/{{ item }}"
    block: "{% if pingresult[item] != '' %}{{ pingresult[item] | default(' ') }}{% else %} {% endif %}"
    marker: "# {mark} {{ checklist.key }}/{{ taskindex }}"
    create: true
  delegate_to: localhost
  with_items:
  - stdout
  - stderr

- debug:
    msg: "complate"
  failed_when: pingresult is failed
```

4. This is dir tree
```
.
├── clear.yml
├── config.yaml
├── description.pdf
├── <group1>
│   ├── 0.yml
│   └── 1.yml
├── init.yml
└── requirements.yml
```

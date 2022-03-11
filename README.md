# nasa-judge-api
NCKU NASA judge api service

- [Install](#Install)
- [Remove](#Remove)
- [Make a git dir for this repo at installed host](#make-a-git-dir-for-this-repo-at-installed-host)
- [Api](#Api)
- [How to write a Lab check code](#how-to-write-a-lab-check-code)
## Install
1. clone this repo and cd into nasa-judge-api.

```bash
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
```

2. run ``install.sh``

```bash
sh install.sh
```

3. get judgeapi wireguard vpn from nasa-judge-backend and put in `/etc/wireguard/judgeapi.conf`
``` bash
sudo systemctl stop wg-quick@judgeapi.service
sudo cp <judgeapi conf path> /etc/wireguard/judgeapi.conf
sudo systemctl start wg-quick@judgeapi.service
```

4. add smb mount point in fstab
``` bash
sudo bash -c "echo \"//172.18.142.254/judgefiles /etc/nasajudgeapi/files  cifs    username=<smbusername>,password=<smbpasswd>   0   0\" >> /etc/fstab"
sudo mount -a
```

5. config sql info in `/etc/nasajudgeapi/db.conf` and restart service
``` bash
sudo vi /etc/nasajudgeapi/db.conf
sudo systemctl restart nasajudgeapi.service
sudo systemctl restart nasasqlsshtunnel.service
```

6. rename your network wan interface to name `wan` and your workernode lan area to name `lan`.
![image](https://user-images.githubusercontent.com/57281249/157760749-37bbc2e8-d626-47cd-87ee-5d0a4658c07f.png)

7. change `iptablesconf.conf` lan ip from `192.168.123.0/24` to your lan ip's network id(it must be /24) and run `setupdefaultiptables.sh` to setup your iptables.
8. set all your worker allow ssh root login ther root `.ssh/id_rsa` and `.ssh/id_rsa.pub` must be same. get your worker's `.ssh/id_rsa.pub` send to frontend and send your nasajudgeapi host's root ssh pub key `.ssh/id_rsa.pub` to your all worker's `.ssh/authorized_keys`
9. use `setupnode.sh` to search and config your worker.
``` bash
bash setupnode.sh <your workernode lan area interface ip> <min> <max>
# ex:
# bash setupnode.sh 192.168.123.254 100 200
```
10. add your student vpn config with `addvpnuser.sh`
``` bash
bash /etc/nasajudgeserver/addvpnuser.sh <username>
```

## Remove
1. clone this repo and cd into nasa-judge-api than run remove.sh
``` bash
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
sh remove.sh
```

## Make a git dir for this repo at installed host
1. clone this repo and cd into nasa-judge-api.

```bash
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
```
2. Run setupgit.sh
```bash
bash setupgit.sh
```

3. cd into `/tmp/nasa-judge-api`
```bash
cd /tmp/nasa-judge-api
```

4. and you can run `git status` and `git diff` to see what you change in `/etc/nasajudgeapi/`
```bash
$ git status
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

## Api
please connect this api on backend with `judgeapi` vpn ip

- `/`
  - run judge
    - `curl -X POST 127.0.0.1 -H "Accept: application/json" --data '{"labId": "Lab01","studentId": "F74104757","data": []}' | jq`
``` json
{
  "external": [
    {
      "message": "linux can ping 8.8.8.8",
      "ans": true,
      "weight": 50
    },
    {
      "message": "sudo can no password",
      "ans": true,
      "weight": 50
    }
  ],
  "internal": []
}
```
- `/alive`
  - for backend to check api is alive
    - `curl 127.0.0.1/alive | jq`
``` json
true
```
- `/serverlist`
  - get api's worker queue
    - `curl 127.0.0.1/serverlist | jq`
``` json
[
  "192.168.123.111",
  "192.168.123.112",
  "192.168.123.113",
  "192.168.123.114",
  "192.168.123.115",
  "192.168.123.116",
  "192.168.123.117",
  "192.168.123.118",
  "192.168.123.119",
  ...
]
```
- `/getdbscore`
  - get student score from backend
    - `curl 127.0.0.1/getdbscore | jq`
``` json
{
  "Lab01": {
    "<studentid>": {
      "score": 100
    },
    "<studentid>": {
      "score": 100
    },
    "<studentid>": {
      "score": 100
    },
    "<studentid>": {
      "score": 100
    },
    "<studentid>": {
      "score": 100
    },
    "<studentid>": {
      "score": 100
    },
    ...
  }
}
```
- `/getdbscore/result`
  - get student score and result from backend
    - `curl 127.0.0.1/getdbscore/result | jq`
``` json
{
  "Lab01": {
    "<studentid>": {
      "score": 100,
      "result": {
        "external": [
          {
            "message": "linux can ping 8.8.8.8",
            "ans": true,
            "weight": 50
          },
          {
            "message": "sudo can no password",
            "ans": true,
            "weight": 50
          }
        ],
        "internal": []
      }
    },
    "<studentid>": {
      "score": 100,
      "result": {
        "external": [
          {
            "message": "linux can ping 8.8.8.8",
            "ans": true,
            "weight": 50
          },
          {
            "message": "sudo can no password",
            "ans": true,
            "weight": 50
          }
        ],
        "internal": []
      }
    },
    ...
  }
}
```

## How to write a Lab check code
1. clone this repo and cd into nasa-judge-api.

```bash
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
```

2. copy `lab/template/` dir to `lab/<Labid>/`
``` bash
cp -r lab/template/ lab/<Labid>/
# cp -r lab/template/ lab/Lab01/
```

3. frontend will give you a judge json data like [exfrontenddata.json](/exfrontenddata.json):

labId, studentId and wanip is default variable. You can add new variable in data. If type is `value` it is variable else if type is `file` it is file.
``` json
{
  "labId": "<labid>",
  "studentId": "<studentid>",
  "wanip": "this value frontend didn't give but it will auto get from wireguard",
  "data": [
    {
      "type": "value",
      "name": "<variable name>",
      "data": "<plain text>"
    },
    {
      "type": "file",
      "name": "<file name>",
      "data": "<base64 data>"
    },
    {
      "type": "value",
      "name": "variable_a",
      "data": "aaa"
    },
    {
      "type": "value",
      "name": "variable_b",
      "data": "bbb"
    },
    {
      "type": "file",
      "name": "test.txt",
      "data": "YWFhYWFhYWFhYWFhCg=="
    }
  ]
}
```
4. Write your lab's [data.json](/lab/template/data.json):

- checkonhost (default is `false`)
  - If it is `true` that mean this lab don't use worker to check VM, it just for check such like student's examination paper.
- external & internal
  - that mean the check points under this attribute will test at external or internal.
  - message
    - your check point narrative
  - args
    - all variable that this check point will use(not file. ps: which variable type is file.)
  - weight
    - how many score in this check point
  - check
    - which check point need to be true
  - checkformula
    - check point formula use with attribute `check`
``` json
{
  "checkonhost": false,
  "external": [
    {
      "message": "<your check point narrative>",
      "args": "{all variable that this check point will use}",
      "weight": <how many score in this check point>,
      "check": {
          "<which check point need to be true>"
      },
      "checkformula": "<check point formula use with attribute \"check\">"
    },
    {
      "message": "example",
      "args": "<wanip> <studentId> <variable_a> <variable_b>",
      "weight": 20
    },
    {
      "message": "linux can ping 8.8.8.8",
      "args": "<wanip> <studentId>",
      "weight": 20
    },
    {
      "message": "sudo can no password",
      "args": "<wanip> <studentId>",
      "weight": 20,
      "check": {
          "external": [1,2],
          "internal": [0]
      },
      "checkformula": "ansdb[\"external\"][1] and ansdb[\"external\"][2] and ansdb[\"internal\"][0]"
    }
  ],
  "internal": [
    {
      "message": "something check in student lan (it will use in NA)",
      "args": "<wanip> <studentId>",
      "weight": 20
    }
  ]
}
```

5. write which package you need to install at worker at [package.conf](/lab/template/package.conf) like:
```
curl
dnsutils
git
jq
lsb-release
sshpass
wget
```

6. Write shell script that you need to do at judge beginning at [start.sh](/lab/template/start.sh). please write your code in the end of file and keep the original code.
7. Write shell script that you need to do at end of judge at [clear.sh](/lab/template/clear.sh). please write your code in the end of file and keep the original code.
8. Write your check point script at [external](/lab/template/external) or [internal](/lab/template/internal) dir. one check point one main script and main script file name must be same as a index in data.json external or internal list, file extension name must be `.sh`.
9. Do not print any thing except `true` or `false` answer at `stdout` in check point script please print at `stderr`.
10. You can use file which frontend give ([exfrontenddata.json](/exfrontenddata.json)) in your check point script with a file name in `name`. For Example:
``` bash
#!/bin/bash

if [ "$(cat test.txt)" != "aaaaaaaaaaaa" ]
then 
  echo false
  exit 0
fi
echo true
```
11. If you want to write all of judge.py by you self please add a file at lab dir. When judge begining, frontend's json will save at `getdata.json`, and output at `stdout` must be like:
> :warning: **If you want to use default `judge.py`, don't add any `judge.py` at lab dir.**
``` json
{
  "external": [
    {
      "message": "linux can ping 8.8.8.8",
      "ans": true,
      "weight": 50
    },
    {
      "message": "sudo can no password",
      "ans": true,
      "weight": 50
    }
  ],
  "internal": []
}
```

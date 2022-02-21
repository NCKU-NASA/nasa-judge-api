# NASA-Judge-Script
Judge Script for NCKU NASA judge api service

- [How to write a Lab check code](#how-to-write-a-lab-check-code)

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

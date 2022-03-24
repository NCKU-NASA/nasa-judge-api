#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

dt="$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 'cat /var/log/pi.log | head -n 1 | awk -v date=$(date +%s) "{print date-\$1}"')"

if [ "$dt" == "" ] || [ "$dt" == "-inf" ] || [ $dt -gt 60 ]
then
    echo false
    exit 0
fi

dt="$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 'sudo journalctl -xe --no-page | grep CRON | grep CMD | grep date | tail -n 2 | awk "{print \$1, \$2, \$3}" | xargs -i date --date={} +%s | awk "BEGIN{ RS = \"\" ; FS = \"\n\" }{print \$2-\$1}"')"

if [ "$dt" == "" ] || [ $dt -ne 60 ]
then
    echo false
    exit 0
fi

dt="$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 'sudo journalctl -xe --no-page | grep CRON | grep CMD | grep date | tail -n 1 | awk "{print \$1, \$2, \$3}" | xargs -i date --date={} +%s | awk -v date=$(date +%s) "{print date-\$1}"')"

if [ "$dt" == "" ] || [ "$dt" == "-inf" ] || [ $dt -gt 60 ]
then
    echo false
    exit 0
fi

echo true
exit 0

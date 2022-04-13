#!/bin/bash
if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo systemctl show pi --no-page 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep CPUQuotaPerSecUSec)" != "CPUQuotaPerSecUSec=100ms" ]
then
    echo false
    exit 0
fi


echo true

#set +e

exit 0

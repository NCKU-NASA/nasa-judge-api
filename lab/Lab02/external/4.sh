#!/bin/bash
if [ $# -lt 1 ]
then
    echo "usage: $0 <wanip>"
    exit 0
fi

#set -e

context=$(sed "s/<wanip>/$1/g" exweb.html | sha256sum | sed "s/[^0-9a-zA-Z]//g")

# testing service is up with curl
if [ "$(curl --connect-timeout 1 -s -w "%{http_code}" -o /dev/null $1:8080 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "200" ]
then
    echo false
    exit 0
fi


# testing services context with curl
if [ "$(echo "$(curl --connect-timeout 1 -s $1:8080 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" | sha256sum | sed "s/[^0-9a-zA-Z]//g")" != "$context" ]
then
    echo false
    exit 0
fi

# testing img url with curl
for imgurl in $(curl --connect-timeout 1 -s $1:8080 | grep -oP "(?<=\<img src=)(.*)(?= width=400px>)")
do
    if [ "$(curl --connect-timeout 1 -s -w "%{http_code}" -o /dev/null $imgurl 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "200" ]
    then
        echo false
        exit 0
    fi
done

echo true

#set -e

exit 0

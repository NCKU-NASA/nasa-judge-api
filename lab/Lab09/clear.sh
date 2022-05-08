#!/bin/bash

ssh $(echo "$3" | awk '{print tolower($0)}')@$2 '
if [ -f ~/.ssh/config.bak ]
then
    if [ -f ~/.ssh/config ]
    then
        if [ "$(cat ~/.ssh/config)" == "$(cat ~/.ssh/config.bak)" ] || [ "$(cat ~/.ssh/config.bak)" == "" ]
        then
            rm ~/.ssh/config.bak
        fi
        rm ~/.ssh/config
    fi

    if [ -f ~/.ssh/config.bak ]
    then
        mv ~/.ssh/config.bak ~/.ssh/config
    fi
fi
'



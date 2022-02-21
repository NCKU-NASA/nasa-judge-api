#!/bin/bash

#if [ $# -lt 1 ]
#then
#    echo "usage: $0 <username>"
#    exit 0
#fi

size=$(sshpass -p finalexam ssh root@192.168.140.2 "mdadm -D \$(df | grep /share | awk '{print \$1}')" | grep "Array Size" | awk '{print $5}' | sed s/\(//g)

echo 3.5 $size 4.5 | awk '{if($2>=$1 && $2<=$3){printf "true\n"}else{printf "false\n"}}'

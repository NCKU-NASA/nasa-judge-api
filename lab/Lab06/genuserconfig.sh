#!bin/bash
groupbag=();
userbag=();
for i in $(seq 15);
do
    groupbag[$i-1]=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5);
done

for i in $(seq 200);
do
    userbag[$i-1]=$(head /dev/urandom | tr -dc a-z0-9 | head -c 7);
done

groupnum=${#groupbag[*]};
echo > userconfig;
for user in ${userbag[@]};
do
    echo -n $user >> userconfig;
    echo -n " $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)" >> userconfig;

    ausergroups=();
    for i in $(seq $(($RANDOM%14)));
    do
       ausergroups[$i-1]=${groupbag[$((RANDOM%groupnum))]};
    done
    ausergroups=($(for group in "${ausergroups[@]}"; do echo "${group}"; done | sort -u));

    for ausergroup in ${ausergroups[@]};
    do
        if [ "$ausergroup" != "${ausergroups[0]}" ];
        then
            echo -n "," >> userconfig;
        else
            echo -n " " >> userconfig;
        fi
        echo -n $ausergroup >> userconfig;
    done
    echo >> userconfig;
done


echo "${groupbag[@]}" > groupbag;
echo "${userbag[@]}" > userbag;
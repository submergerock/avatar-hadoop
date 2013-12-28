#!/usr/bin/env bash

num=$1
name=$2
hostname=$(hostname)

IP=$(cat /etc/hosts | grep "$hostname" | awk '{print $1}')
while [ $num -gt 0 ]
        do
	   nohup /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -mkdir  /tmp/$IP/$name &
            sleep 2
        echo sleep 2
	echo "$IP:  hadoop dfs -mkdir  $name"	
	    num=`expr  $num  -  1`	
	#echo "$num"
	    name=`expr $name - 1`
	#echo "$name"
	done

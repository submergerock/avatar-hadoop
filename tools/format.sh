#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  path=$1
else
  path=/usr/local/hadoop/block/
fi
echo
echo HADOOP_HOME = /usr/local/hadoop-0.20.1-dev-patch
echo

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/masters"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then 
 echo AvatarNode0 is formatting
 ssh $IP rm -r -f /usr/local/hadoop/avatarshare/share0/*
 ssh $IP rm -r -f /usr/local/hadoop/local/*
 ssh $IP rm -r -f /home/wl826214/hadoop/*
 
 ssh $IP /usr/local/hadoop-0.20.1-dev-patch/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -zero -format
 fi
 if  [ $mun == 1  ] ;
 then
 echo AvatarNode1 is formatting
 ssh $IP rm -r -f /usr/local/hadoop/avatarshare/share1/*
 ssh $IP rm -r -f /usr/local/hadoop/local/*
 ssh $IP rm -r -f /home/wl826214/hadoop/*
 ssh $IP /usr/local/hadoop-0.20.1-dev-patch/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -one -format
 fi

 mun=`expr $mun + 1` 
done

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo $IP is formatting
 echo ssh $IP rm $path*
 echo ssh $IP rm -r $path*
 ssh $IP rm $path*
 ssh $IP rm -r $path*
 

done


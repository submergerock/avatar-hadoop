#!/usr/bin/env bash

if [ $# -le 3 ]; then
  echo "test01_logimage_reuse.sh  <avatarnode0Local> <avatarnode0NFS> <avatarnode1Local> <avatarnode1NFS>"
  exit 1
fi
echo

HOSTLIST="${HADOOP_HOME}/conf/masters"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 avatarnode0IP=$IP
 fi
 if  [ $mun == 1  ] ;
 then
 avatarnode1IP=$IP
 fi

 mun=`expr $mun + 1` 
done

#avatarnode0IP=$1
avatarnode0Local=$1
avatarnode0NFS=$2

#avatarnode1IP=$4
avatarnode1Local=$3
avatarnode1NFS=$4
echo avatarnode0IP = $avatarnode0IP
echo avatarnode0Local = $avatarnode0Local
echo avatarnode0NFS = $avatarnode0NFS
echo avatarnode1IP = $avatarnode1IP
echo avatarnode1Local = $avatarnode1Local
echo avatarnode1NFS = $avatarnode1NFS
echo HADOOP_HOME = $HADOOP_HOME
echo
sleep 3
echo \******************************************
echo \*    1.   delete editlog and fsimage     \*
echo \******************************************
echo
sleep 3

ssh $avatarnode0IP rm -r -f $avatarnode0Local/*
ssh $avatarnode1IP rm -r -f $avatarnode1Local/*
ssh $avatarnode0IP rm -r -f $avatarnode0NFS/*
ssh $avatarnode1IP rm -r -f $avatarnode1NFS/*

#ssh $avatarnode0IP rm -r -f /home/wl826214/hadoop/local/*
#ssh $avatarnode1IP rm -r -f /home/wl826214/hadoop/local/*
#rm -r -f /home/wl826214/sharedir/share0/*
#rm -r -f /home/wl826214/sharedir/share1/*

echo
echo \******************************************
echo \*    2.   format editlog and fsimage     \*
echo \******************************************
echo
sleep 3
#ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -zero -format
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -zero -format
sleep 3
#ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -one -format
ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -one -format
sleep 3

echo
echo \******************************************************************
echo \*    3.   start avatarnode0 as primary and avatarnode1 as standby\*     
echo \******************************************************************
echo
sleep 3
$HADOOP_HOME/bin/a-start-avatar-0p.sh
sleep 3
$HADOOP_HOME/bin/a-start-avatar-1s.sh

echo
echo \******************************************
echo \*    4.   mkdir on avatarnode0           \*
echo \******************************************
echo
sleep 3
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop dfs -ls
sleep 3
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop dfs -mkdir 000
sleep 3
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop dfs -ls
sleep 3


echo
echo \******************************************
echo \*    5.   stop avatarnode0               \*
echo \******************************************
echo
sleep 3
$HADOOP_HOME/bin/a-stop-avatar.sh -zero
sleep 3

echo
echo \**************************************************
echo \*    6.   set avatarnode1 from standby to primary*
echo \**************************************************
echo
sleep 3
$HADOOP_HOME/bin/a-avatar-s-set-p.sh
sleep 3

echo
echo \******************************************
echo \*    7.   mkdir on avatarnode1           \*
echo \******************************************
echo
sleep 3
ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop dfs -ls
sleep 3
ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop dfs -mkdir 111
sleep 3
ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop dfs -ls
sleep 3

echo
echo \******************************************
echo \*    8.   stop avatarnode1               \*
echo \******************************************
echo
sleep 3
$HADOOP_HOME/bin/a-stop-avatar.sh -one
sleep 3

echo
echo \******************************************
echo \*    9.   copy editlog and image from      \*
echo \*         avatarnode1 to avatarnode0     \*
echo \******************************************
echo
sleep 3
ssh $avatarnode1IP scp -r  $avatarnode1Local/* $avatarnode0IP:$avatarnode0Local/
sleep 3
ssh $avatarnode1IP scp -r  $avatarnode1Local/* $avatarnode0IP:$avatarnode0NFS/
sleep 3

echo
echo
echo \******************************************
echo \*    10.  restart avatarnode0 as primary\*
echo \******************************************
echo
sleep 3
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -zero
sleep 3

echo
echo \******************************************
echo \*    11.  restart avatarnode1 as standby\*
echo \******************************************
echo
sleep 3
$HADOOP_HOME/bin/a-start-avatar-1s.sh
sleep 3

echo
echo \******************************************
echo \*    12.  ls on avatarnode1              \*
echo \******************************************
echo
sleep 3
ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop dfs -ls

sleep 3

echo
echo \******************************************
echo \*    13.  stop avatarnode1              \*
echo \******************************************
echo
sleep 3
$HADOOP_HOME/bin/a-stop-avatar.sh -one

echo
echo \******************************************
echo \*    there will be a error         \*
echo \******************************************
echo

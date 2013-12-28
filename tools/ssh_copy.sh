#!/usr/bin/env bash

if [ $# -le 0 ]; then
  echo "ssh_copy.sh  <password>"
  exit 1
fi

username=$(whoami)

root=$(echo `whoami` | grep "root")

if [ -n "$root" ]; then
userpath=/root
else
userpath=/home/$username
fi
echo HADOOP_HOME is ${HADOOP_HOME}

HostName=$(hostname) 
#cp $userpath/.ssh/id_dsa.pub $userpath/.ssh/$HostName.pub

echo
echo \************************************************************************************
echo \*    6.   remote copy *.pub \*
echo \************************************************************************************
echo
sleep 1

HOSTLIST="${HADOOP_HOME}/conf/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo ssh $IP 
 echo ${HADOOP_HOME}/tools/ssh_expect_scp.sh $IP $HostName $1 $userpath
 ${HADOOP_HOME}/tools/ssh_expect_scp.sh $IP $HostName $1 $userpath
done

HOSTLIST="${HADOOP_HOME}/conf/masters"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo ssh $IP 
 echo ${HADOOP_HOME}/tools/ssh_expect_scp.sh $IP $HostName $1 $userpath
 ${HADOOP_HOME}/tools/ssh_expect_scp.sh $IP $HostName $1 $userpath
done

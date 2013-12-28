#!/usr/bin/env bash
if [ $# -le 0 ]; then
  echo "ssh_IP_hostname.sh  <password>"
  exit 1
fi
echo
echo \************************************************************************************
echo \*       ssh IP hostname \*
echo \************************************************************************************
echo
sleep 1

HOSTLIST="${HADOOP_HOME}/conf/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo ssh $IP 
 echo ${HADOOP_HOME}/tools/ssh_expect_IP_hostname.sh $IP  $1
 ${HADOOP_HOME}/tools/ssh_expect_IP_hostname.sh $IP  $1
done

HOSTLIST="${HADOOP_HOME}/conf/masters"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo ssh $IP 
 echo ${HADOOP_HOME}/tools/ssh_expect_IP_hostname.sh $IP $1
 ${HADOOP_HOME}/tools/ssh_expect_IP_hostname.sh $IP  $1
done

#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  path=$1
else
  path=/usr/local/hadoop/block/
fi
echo
echo HADOOP_HOME = $HADOOP_HOME
echo

HOSTLIST="${HADOOP_HOME}/conf/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo reboot $IP
  ssh $IP nohup $HADOOP_HOME/tools/reboot.sh &
done

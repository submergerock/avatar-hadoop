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

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo reboot $IP
 ssh $IP nohup /usr/local/hadoop-0.20.1-dev-patch/tools/reboot.sh &

done





HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo reboot $IP
  ssh $IP nohup /usr/local/hadoop-0.20.1-dev-patch/tools/reboot.sh &
done

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/clients"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo reboot $IP
  ssh $IP nohup /usr/local/hadoop-0.20.1-dev-patch/tools/reboot.sh &
done
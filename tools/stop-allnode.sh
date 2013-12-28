#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  path=$1
else
  path=/usr/local/hadoop/block/
fi
echo
echo HADOOP_HOME = $HADOOP_HOME
echo

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/masters"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo shutdown $IP
 ssh $IP nohup /usr/local/hadoop-0.20.1-dev-patch/tools/poweroff.sh &

done





HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo shutdown $IP
  ssh $IP nohup /usr/local/hadoop-0.20.1-dev-patch/tools/poweroff.sh &
done

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/clients"
echo shutdown $IP
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
  ssh $IP nohup /usr/local/hadoop-0.20.1-dev-patch/tools/poweroff.sh &
done

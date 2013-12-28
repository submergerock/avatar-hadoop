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
 echo $IP is formatting
 echo ssh $IP rm $path*
 echo ssh $IP rm -r $path*
 ssh $IP rm $path*
 ssh $IP rm -r $path*
 

done


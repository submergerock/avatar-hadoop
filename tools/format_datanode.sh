#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  path=$1
else
  path=/usr/local/hadoop/block/
fi
echo
echo HADOOP_HOME = /usr/local/hadoop-0.20.1-dev-patch
echo



HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo $IP is formatting
 echo ssh $IP rm $path*
 echo ssh $IP rm -r $path*
 ssh $IP rm $path*
 ssh $IP rm -r $path*
 

done


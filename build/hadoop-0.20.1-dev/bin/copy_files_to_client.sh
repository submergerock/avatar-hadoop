#!/usr/bin/env bash
if [ $# -le 1 ]; then
  echo "copy_files_to_client.sh  <srcfilename> <destfilename>"
  exit 1
fi
echo


srcfilename=$1
destfilename=$2

echo srcfilename = $srcfilename
echo destfilename = $destfilename
echo HADOOP_HOME = $HADOOP_HOME
echo



HOSTLIST="${HADOOP_HOME}/conf/clients"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo $IP is copying
 echo scp $srcfilename $IP:$destfilename
 scp $srcfilename $IP:$destfilename
 

done


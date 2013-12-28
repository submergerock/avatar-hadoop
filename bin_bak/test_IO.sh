#!/usr/bin/env bash
if [ $# -le 2 ]; then
  echo "write.sh  <sum of files> <filesize(B)> <sum of client> [read|write]"
  exit 1
fi
echo

  sumoffiles=$1
  filesize=$2
  read=""
  write=""
if [ $# -eq 4 ] ; then
  read=`echo $@|grep -ri  "read"`
  write=`echo $@|grep -ri  "write"`

fi

echo read = $read
echo write = $write

if [ -z "$read" -a -z "$write" ] ; then
  read="read"
  write="write"
elif [ -n "$read" -a -z "$write" ] ; then
   read="read"
  write=""
elif [ -z "$read" -a -n "$write" ] ; then
   read=""
  write="write"
else
   echo
fi

echo read = $read
echo write = $write

echo sumoffiles = $sumoffiles
echo filesize = $filesize

echo HADOOP_HOME = $HADOOP_HOME
echo




if [ -n "$write" ] ; then
HOSTLIST="${HADOOP_HOME}/conf/clients"
mun=$3
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 
 echo ============writing file to hdfs on $IP=================
  ssh $IP  nohup /usr/local/hadoop-0.20.1-dev/bin/write_to_hdfs.sh $sumoffiles $filesize &

 if  [ $mun -eq 1 ]; then
  break
 fi

 mun=`expr $mun - 1` 
done
fi



sleep  10
if [ -n "$read" ] ; then


HOSTLIST="${HADOOP_HOME}/conf/clients"
mun=$3
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
  echo ============reading file to hdfs on $IP============

  ssh $IP nohup /usr/local/hadoop-0.20.1-dev/bin/read_from_hdfs.sh &

 if  [ $mun -eq 1 ]; then
  break
 fi

 mun=`expr $mun - 1` 
done
fi

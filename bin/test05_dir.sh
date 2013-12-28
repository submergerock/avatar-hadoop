#!/usr/bin/env bash
if [ $# -le 2 ]; then
  echo "test05_dir.sh  <sum of dirs> <dirname>  [mkdir|rmdir]"
  exit 1
fi
echo

  sumofdirs=$1
  dirname=$2
 
echo sumofdirs = $sumofdirs
echo dirname = $dirname

echo HADOOP_HOME = $HADOOP_HOME
 mkdir=""
  rmdir=""
if [ $# -eq 3 ] ; then
  mkdir=`echo $@|grep -ri  "mkdir"`
  rmdir=`echo $@|grep -ri  "rmdir"`

fi

echo mkdir = $mkdir
echo rmdir = $rmdir

if [ -z "$mkdir" -a -z "$rmdir" ] ; then
  mkdir="mkdir"
  rmdir="rmdir"
elif [ -n "$mkdir" -a -z "$rmdir" ] ; then
   mkdir="mkdir"
  rmdir=""
elif [ -z "$mkdir" -a -n "$rmdir" ] ; then
   mkdir=""
  rmdir="rmdir"
else
   echo
fi

echo read = $read
echo write = $write


echo
if [ -n "$mkdir" ] ; then

echo ============mkdir to hdfs on 192.168.1.13=================
  ssh 192.168.1.13  nohup /usr/local/hadoop-0.20.1-dev/bin/mkdir.sh $sumofdirs $dirname &
echo ============mkdir to hdfs on 192.168.1.14=================
  ssh 192.168.1.14  nohup /usr/local/hadoop-0.20.1-dev/bin/mkdir.sh $sumofdirs $dirname &
echo ============mkdir to hdfs on 192.168.1.19=================
  ssh 192.168.1.19  nohup /usr/local/hadoop-0.20.1-dev/bin/mkdir.sh $sumofdirs $dirname &
echo ============mkdir to hdfs on 192.168.1.20=================
  ssh 192.168.1.20  nohup /usr/local/hadoop-0.20.1-dev/bin/mkdir.sh $sumofdirs $dirname &

fi



if [ -n "$rmdir" ] ; then
sleep  2
echo ============rmdir to hdfs on 192.168.1.13=================
  ssh 192.168.1.13  nohup /usr/local/hadoop-0.20.1-dev/bin/rmdir.sh $sumofdirs $dirname &
echo ============rmdir to hdfs on 192.168.1.14=================
  ssh 192.168.1.14  nohup /usr/local/hadoop-0.20.1-dev/bin/rmdir.sh $sumofdirs $dirname &
echo ============rmdir to hdfs on 192.168.1.19=================
  ssh 192.168.1.19  nohup /usr/local/hadoop-0.20.1-dev/bin/rmdir.sh $sumofdirs $dirname &
echo ============rmdir to hdfs on 192.168.1.20=================
  ssh 192.168.1.20  nohup /usr/local/hadoop-0.20.1-dev/bin/rmdir.sh $sumofdirs $dirname &

fi
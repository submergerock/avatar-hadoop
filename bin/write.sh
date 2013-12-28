#!/usr/bin/env bash
if [ $# -le 1 ]; then
  echo "write.sh  <sum of files> <filesize(KB)> <second>"
  exit 1
fi
echo

  sumoffiles=$1
  filesize=$2
  second=$3

echo sumoffiles = $sumoffiles
echo filesize = $filesize

echo HADOOP_HOME = $HADOOP_HOME
echo

/usr/local/hadoop-0.20.1-dev/bin/makefile /tmp/test.iso $filesize

n=0

while [ $sumoffiles -gt 0 ]
        do
	filename=`expr  $n  +  10000`
	echo copying tmp/test.iso  to /tmp/$filename
	
	nohup /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -copyFromLocal /tmp/test.iso  /tmp/$filename &

	   sleep $second
	    sumoffiles=`expr  $sumoffiles  -  1`
            n=`expr  $n  +  1`	
	echo
done

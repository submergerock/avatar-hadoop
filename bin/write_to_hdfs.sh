#!/usr/bin/env bash
if [ $# -le 2 ]; then
  echo "write_to_hdfs.sh  <sum of files> <filesize(KB)> <second>"
  exit 1
fi
echo


sumoffiles=$1
filesize=$2
second=$3
rm /tmp/sumoffiles
echo "$sumoffiles" >> /tmp/sumoffiles
echo " " >> /tmp/log
date=$(date)
echo "=============================$date=========================" >> /tmp/log

echo "write $sumoffiles $filesize files to hdfs" >> /tmp/log


#echo sumoffiles = $sumoffiles
#echo filesize = $filesize
echo HADOOP_HOME = $HADOOP_HOME
echo
echo
echo \******************************************
echo \*    1.  get hostname and IP \*
echo \******************************************
echo

 hostname=$(hostname)

echo hostname = $hostname
IP=$(cat /etc/hosts | grep "$hostname" | awk '{print $1}')
echo IP = $IP

echo
echo IP = $IP
echo \******************************************
echo \*    2.  check lock \*
echo \******************************************
echo IP = $IP
echo
i=1

while [ i > 0 ]
do
lockfile=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "lock" | awk '{print $8}')
if  [ -z $lockfile ] ; then
 
  break
  
else
echo $IP sleeping
  sleep 10
 fi
done
echo
echo IP = $IP
echo \******************************************
echo \*   3.   lock \*
echo \******************************************
echo IP = $IP
echo


nohup dd if=/dev/zero of=/tmp/lock ibs=1K count=1  &
/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -copyFromLocal /tmp/lock  /tmp/$IP/lock

echo locked

echo
echo IP = $IP
echo \******************************************
echo \*   4.   create a file \*
echo \******************************************
echo IP = $IP
echo

/usr/local/hadoop-0.20.1-dev/bin/makefile /tmp/test.iso $2
/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -mkdir  /tmp/$IP

ISO=$(ls /tmp/test.iso -al)

echo $ISO

echo
echo IP = $IP
echo \******************************************
echo \*   5.   check total of files on hdfs in /tmp/$IP/ \*
echo \******************************************
echo IP = $IP
echo

sumoffile=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "Found" | awk '{print $2}')


if  [ -z $sumoffile ] ; then
  sumoffile=0
 fi
echo sumoffile=$sumoffile
num=$1
n=`expr  $sumoffile  +  0`
echo num=$num
echo n=$n
echo
echo
echo IP = $IP
echo \******************************************
echo \*   6.  copy files to hdfs\*
echo \******************************************
echo IP = $IP
echo


while [ $num -gt 0 ]
        do
	filename=`expr  $n  +  10000`
	echo copying tmp/test.iso  to /tmp/$IP/$filename
	echo " " >> /tmp/log
	echo "copying tmp/test.iso  to /tmp/$IP/$filename" >> /tmp/log
	   #nohup /usr/local/hadoop-0.20.1-dev/bin/hadoop jar  /usr/local/hadoop-0.20.1-dev/bin/test_hdfs_IO.jar test_hdfs_IO write /tmp/test.iso  /tmp/$IP/$filename &
	nohup /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -copyFromLocal /tmp/test.iso  /tmp/$IP/$filename &

	   sleep $second
	    num=`expr  $num  -  1`
            n=`expr  $n  +  1`	
	echo
done
echo
echo IP = $IP
echo \******************************************
echo \*   7.  unlock\*
echo \******************************************
echo IP = $IP
echo

i=1
while [ i > 0 ]
do
/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -rm -skipTrash /tmp/$IP/lock
lockfile=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "lock" | awk '{print $8}')
if  [ -z $lockfile ] ; then
 
  break
  
else
echo $IP unlocking
  sleep 10
 fi
done
echo unlocked
echo
echo IP = $IP
echo \******************************************
echo \*   8.  check if the file has been copied to hdfs successfully\*
echo \******************************************
echo IP = $IP
echo

num=$1
n=`expr  $sumoffile  +  0`
while [ $num -gt 0 ]
        do
	filename=`expr  $n  +  10000`

msg=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls  /tmp/$IP/$filename | grep tmp | awk '{print $5}')

 if  [ -z "$msg"  ] ; then
  echo "The file  failed to copy to /tmp/$IP/$filename on hdfs " >> /tmp/log
 elif [ $msg -eq 0  ] ; then
  echo "The file size of  /tmp/$IP/$filename is 0 " >> /tmp/log
 elif [ $msg -eq $filesize ] ; then
  echo "The file copy to /tmp/$IP/$filename on hdfs successfully" >> /tmp/log
 else
echo "The file unsuccessfully copy to /tmp/$IP/$filename on hdfs " >> /tmp/log
fi
            num=`expr  $num  -  1`
            n=`expr  $n  +  1`	

done




date=$(date)
echo "=============================$date=========================" >> /tmp/log
echo " " >> /tmp/log

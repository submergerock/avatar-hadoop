#!/usr/bin/env bash

if [ $# -le 0 ]; then
  echo "read_from_hdfs_IP.sh  <Remote Host IP>"
  exit 1
fi
echo



echo
echo \******************************************
echo \*    1.  get hostname and IP \*
echo \******************************************
echo
hostname=$(hostname)

echo hostname = $hostname
LocalIP=$(cat /etc/hosts | grep "$hostname" | awk '{print $1}')

IP=$1
echo LocalIP = $LocalIP
echo IP = $IP
echo HADOOP_HOME = $HADOOP_HOME
echo " " >> /tmp/$IP/log


date=$(date)
echo "=============================$date=========================" >> /tmp/$IP/log
echo "read files of $IP from hdfs" >> /tmp/$IP/log


echo
echo \******************************************
echo \*    2.  copy  $IP/tmp/test.iso to $LocalIP:/tmp/$IP/test.iso \*
echo \******************************************
echo

ssh $IP scp /tmp/test.iso $LocalIP:/tmp/$IP/test.iso
echo
echo
echo IP = $IP
echo \******************************************
echo \*    3.  read remote host sumoffiles \*
echo \******************************************
echo IP = $IP
echo


mkdir /tmp/$IP
ssh $IP scp /tmp/sumoffiles $LocalIP:/tmp/$IP/sumoffiles

sumoffile=$(cat /tmp/$IP/sumoffiles)

echo
echo IP = $IP
echo \******************************************
echo \*    4.  check lock \*
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
echo $ILocalIP sleeping
  sleep 10
 fi
done


echo
echo IP = $IP
echo \******************************************
echo \*    5.  check total of files on hdfs in /tmp/$IP/ \*
echo \******************************************
echo IP = $IP
echo


num=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "Found" | awk '{print $2}')
echo $IP : $sumoffile
echo hdfs : $num
if [ -z $num ] ; then
  num=0
fi
if [ -z $sumoffile ] ; then
  sumoffile=0
fi

rm /tmp/$IP/difffile
if [ $sumoffile -ne $num ] ; then 
echo total of files error
echo "total of files error:" >> /tmp/$IP/difffile
echo "total of files error:" >> /tmp/$IP/log
echo "$IP : $sumoffile" >> /tmp/$IP/difffile
echo "$IP : $sumoffile" >> /tmp/$IP/log
echo "hdfs : $num" >> /tmp/$IP/difffile
echo "hdfs : $num" >> /tmp/$IP/log
fi


echo
echo IP = $IP
echo \******************************************
echo \*    6.  read the first file  in /tmp/$IP/ on hdfs \*
echo \*    and match the two file \*
echo \******************************************
echo IP = $IP
echo
n=2
while [ $num > 0 ]
        do
##############check the first file  in /tmp/$IP/ on hdfs###############
         file=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "$IP" | awk '{print $8}' | head -n1)
         #file=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/  | awk '{print $8}' | head -n$n | tail -n1)
      if  [ -z $file ] ; then
  	break
      fi
      echo cut $file to /tmp/$IP/t.iso
      echo "cut $file to /tmp/$IP/t.iso" >> /tmp/$IP/log
	 /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -get $file /tmp/$IP/t.iso
         dif=$(diff /tmp/$IP/t.iso /tmp/$IP/test.iso | awk '{print $6}')
##############match the two file  ###############
if  [ -z $dif ] ; then
  echo the two files is same 
  echo "the two files is same" >> /tmp/$IP/log
else
  echo the two files is different  
  echo "******the two files is different******" >> /tmp/$IP/log
    difffile=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "$IP" | head -n1)
    testfile=$(ls /tmp/$IP/test.iso -la)
    echo difffile = $difffile
    echo testfile = $testfile

    echo "==================" >> /tmp/$IP/difffile
    echo "hdfsfile" >> /tmp/$IP/difffile
    echo "hdfsfile" >> /tmp/$IP/log
    echo "$difffile" >> /tmp/$IP/difffile
    echo "$difffile" >> /tmp/$IP/log
    echo "localfile" >> /tmp/$IP/difffile
    echo "localfile" >> /tmp/$IP/log
    echo "$testfile" >> /tmp/$IP/difffile
    echo "$testfil" >> /tmp/$IP/log
 fi
         /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -rm -skipTrash $file	
         rm /tmp/$IP/t.iso 	
	    num=`expr  $num  -  1`	
	    n=`expr  $n  +  1`
	echo
done
date=$(date)
echo "=============================$date=========================" >> /tmp/$IP/log
echo "read files of $IP from hdfs" >> /tmp/$IP/log
echo " " >> /tmp/$IP/log

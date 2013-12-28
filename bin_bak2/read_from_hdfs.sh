#!/usr/bin/env bash


##############get hostname and IP###############
 hostname=$(hostname)

echo hostname = $hostname
IP=$(cat /etc/hosts | grep "$hostname" | awk '{print $1}')
echo HADOOP_HOME = $HADOOP_HOME
echo

##############check lock###############

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





##############check total of files on hdfs in /tmp/$IP/###############
num=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "Found" | awk '{print $2}')
echo



while [ $num > 0 ]
        do
##############check the first file  in /tmp/$IP/ on hdfs###############
         file=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$IP/ | grep "$IP" | awk '{print $8}' | head -n1)
      if  [ -z $file ] ; then
  	break
      fi
      echo cut $file to tmp/t.iso
	 /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -get $file /tmp/t.iso 
         dif=$(diff /tmp/t.iso /tmp/test.iso | awk '{print $6}')
##############match the two file  ###############
if  [ -z $dif ] ; then
  echo the two files is same 
else
  echo the two files is different  
 fi
         /usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -rm -skipTrash $file	
         rm /tmp/t.iso 	
	    num=`expr  $num  -  1`	
	echo
	done



#!/usr/bin/env bash


HOSTLIST="${HADOOP_HOME}/conf/masters"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 avatarnode0IP=$IP
 avatarnode0Name=$(ssh $avatarnode0IP hostname)
 fi
 if  [ $mun == 1  ] ;
 then
 avatarnode1IP=$IP
 avatarnode1Name=$(ssh $avatarnode1IP hostname)
 fi

 mun=`expr $mun + 1` 
done

second=1

sleep $second
echo
echo \************************************************************************************
echo \*    remote copy the compiled version  to avatardatanode \*
echo \************************************************************************************
echo
sleep $second
HOSTLIST="${HADOOP_HOME}/conf/slaves"
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do

 echo $IP is copying
 
 Name=$(ssh $IP hostname) 

 echo "127.0.0.1 localhost" >> $HADOOP_HOME/tmp
 echo "$avatarnode0IP $avatarnode0Name" >> $HADOOP_HOME/tmp
 echo "$avatarnode1IP $avatarnode1Name" >> $HADOOP_HOME/tmp
 echo "$IP $Name" >> $HADOOP_HOME/tmp

 cat $HADOOP_HOME/tmp
 
 scp $HADOOP_HOME/tmp $IP:$HADOOP_HOME/hosts
 rm $HADOOP_HOME/tmp
 
 ssh $IP  chmod 777 $HADOOP_HOME/bin/config_hosts.sh
 ssh $IP  $HADOOP_HOME/bin/config_hosts.sh


done

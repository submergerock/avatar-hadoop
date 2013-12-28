#!/usr/bin/env bash


if [ $# -eq 0 ]; then
    second=5
fi

if [ $# -eq 1 ]; then
    second=$1
fi

HOSTLIST="${HADOOP_HOME}/conf/masters"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 avatarnode0IP=$IP
 fi
 if  [ $mun == 1  ] ;
 then
 avatarnode1IP=$IP
 fi

 mun=`expr $mun + 1` 
done

HOSTLIST="${HADOOP_HOME}/conf/clients"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 client=$IP
 fi
 
 mun=`expr $mun + 1` 
done



echo avatarnode0IP = $avatarnode0IP
echo avatarnode1IP = $avatarnode1IP
echo client = $client
echo second = $second
echo HADOOP_HOME = $HADOOP_HOME
echo


echo
echo \******************************************
echo \*    1.  stop avatarnode and avatardatanode \*
echo \******************************************
echo
sleep $second
$HADOOP_HOME/bin/stop-avatar.sh
sleep 10
sleep $second


echo
echo \******************************************
echo \*    2.   format avatarnode and avatardatanode     \*
echo \******************************************
echo
sleep $second
$HADOOP_HOME/tools/format.sh
sleep $second


echo
echo \******************************************************************
echo \*    3.   start ucarp  manually  \*     
echo \******************************************************************
echo
sleep $second
nu=10
while [ $nu -gt 0 ]
        do
	    sleep 1
	    nu=`expr  $nu  -  1`
	echo start ucarp  manually	
	echo left second $nu
	done

sleep $second

echo
echo \******************************************************************
echo \*    4.   start avatar    \*     
echo \******************************************************************
echo
sleep $second
$HADOOP_HOME/bin/start-avatar.sh
sleep 10

echo
echo \******************************************
echo \*    5.   write 4g file to hdfs           \*
echo \******************************************
echo
sleep $second
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop dfs -ls
sleep $second
$HADOOP_HOME/bin/test_IO.sh 1 4000000000 1 write


##############check file###############

echo
echo \******************************************
echo \*    6.   check if file is copying           \*
echo \******************************************
echo
i=1

while [ i > 0 ]
do
sumoffile=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop dfs -ls /tmp/$client/ | grep Found | awk '{print $2}')
echo sumoffile = $sumoffile
if  [ $sumoffile -ge 2 ] ; then
  echo find file
 sleep 10
  break
  
else

echo  sleeping
  sleep 1
 fi
done



echo
echo \******************************************
echo \*    7.   stop ucarp of avatarnode0 manually\*
echo \******************************************
echo
sleep $second
nu=10
while [ $nu -gt 0 ]
        do
	    sleep 1
	    nu=`expr  $nu  -  1`
	echo stop ucarp  manually	
	echo left second $nu
	done

sleep $second

echo
echo \**************************************************
echo \*    8.   set avatarnode1 from standby to primary \*
echo \*    there will be an error           \*
echo \**************************************************
echo
sleep $second
$HADOOP_HOME/bin/a-avatar-s-set-p.sh
sleep $second


echo
echo \******************************************
echo \*    9.  ls on avatarnode1              \*
echo \******************************************
echo
sleep $second
ssh $avatarnode1IP $HADOOP_HOME/bin/hadoop dfs -ls /tmp/$client/

sleep $second

echo
echo \******************************************
echo \*    9.  ls on avatarnode0              \*
echo \******************************************
echo
sleep $second
ssh $avatarnode0IP $HADOOP_HOME/bin/hadoop dfs -ls /tmp/$client/

sleep 20

echo
echo \******************************************
echo \*    10.  stop avatarnode and avatardatanode \*
echo \******************************************
echo
sleep $second
$HADOOP_HOME/bin/stop-avatar.sh

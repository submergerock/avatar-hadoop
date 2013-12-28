#!/usr/bin/env bash

if [ $# -le 1 ]; then
  echo "avatarnode_install.sh <sum of datanode> <sum of client> <second>"
  exit 1
fi
echo

    second=5


if [ $# -eq 3 ]; then
    second=$3
fi


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

sleep $second
echo avatarnode0IP = $avatarnode0IP
echo avatarnode0Name = $avatarnode0Name
echo avatarnode1IP = $avatarnode1IP
echo avatarnode1Name = $avatarnode1Name
echo  HADOOP_HOME = $HADOOP_HOME

echo
echo \************************************************************************************
echo \*    1.   compile avatar           \*
echo \************************************************************************************
echo
sleep $second
cd $HADOOP_HOME
cp $HADOOP_HOME/conf/* $HADOOP_HOME/conf_bak/
cp $HADOOP_HOME/bin/* $HADOOP_HOME/bin_bak/


#ant -Djava5.home=$Java5Home compile tar
sleep $second

echo "#!/usr/bin/env bash" >> $HADOOP_HOME/tmp
echo "echo \"826214\" | sudo -S cp /usr/local/hadoop-0.20.1-dev/hosts /etc/" >> $HADOOP_HOME/tmp
cp $HADOOP_HOME/tmp $HADOOP_HOME/bin_bak/config_hosts.sh
rm $HADOOP_HOME/tmp



echo
echo \************************************************************************************
echo \*    2.   copy some files to the compiled version  \*
echo \************************************************************************************
echo
sleep $second
cp $HADOOP_HOME/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $HADOOP_HOME/lib/

cp $HADOOP_HOME/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $HADOOP_HOME/build/hadoop-0.20.1-dev/lib/

echo "826214" | sudo -S chmod 777 $HADOOP_HOME/conf_bak/*

echo "826214" | sudo -S chmod 777 $HADOOP_HOME/bin_bak/*

cp $HADOOP_HOME/conf_bak/* $HADOOP_HOME/conf/
cp $HADOOP_HOME/conf/* $HADOOP_HOME/build/hadoop-0.20.1-dev/conf/


cp $HADOOP_HOME/bin_bak/* $HADOOP_HOME/bin/
cp $HADOOP_HOME/bin/* $HADOOP_HOME/build/hadoop-0.20.1-dev/bin/



sleep $second
echo
echo \************************************************************************************
echo \*    3. remote copy the compiled version  to primary and standby \*
echo \************************************************************************************
echo
sleep $second
ssh $avatarnode0IP mkdir $HADOOP_HOME
ssh $avatarnode1IP mkdir $HADOOP_HOME

ssh $avatarnode0IP mkdir /usr/local/hadoop
ssh $avatarnode0IP mkdir /usr/local/hadoop/avatarshare
ssh $avatarnode0IP mkdir /usr/local/hadoop/avatarshare/share0
ssh $avatarnode0IP mkdir /usr/local/hadoop/local
ssh $avatarnode0IP mkdir /usr/local/tmp

ssh $avatarnode1IP mkdir /usr/local/hadoop/avatarshare/share1
ssh $avatarnode1IP mkdir /usr/local/hadoop/local
ssh $avatarnode1IP mkdir /usr/local/tmp


#echo scp -r $HADOOP_HOME/build/hadoop-0.20.1-dev $avatarnode0IP:$HADOOP_HOME

#nohup scp -r $HADOOP_HOME/build/hadoop-0.20.1-dev/ $avatarnode0IP:$HADOOP_HOME/..
#nohup scp -r $HADOOP_HOME/build/hadoop-0.20.1-dev/ $avatarnode1IP:$HADOOP_HOME/..




ssh $avatarnode0IP  cp $HADOOP_HOME/conf/core-site-avatarnode0.xml  $HADOOP_HOME/conf/core-site.xml
ssh $avatarnode0IP  cp $HADOOP_HOME/conf/hdfs-site-avatarnode0.xml  $HADOOP_HOME/conf/hdfs-site.xml 

echo ssh $avatarnode1IP  cp $HADOOP_HOME/conf/core-site-avatarnode1.xml  $HADOOP_HOME/conf/core-site.xml
ssh $avatarnode1IP  cp $HADOOP_HOME/conf/core-site-avatarnode1.xml  $HADOOP_HOME/conf/core-site.xml
ssh $avatarnode1IP  cp $HADOOP_HOME/conf/hdfs-site-avatarnode1.xml  $HADOOP_HOME/conf/hdfs-site.xml 

sleep $second
echo
echo \************************************************************************************
echo \*    4. config /etc/hosts on primary and standby \*
echo \************************************************************************************
echo
sleep $second
echo "127.0.0.1 localhost" >> $HADOOP_HOME/tmp
echo "$avatarnode0IP $avatarnode0Name" >> $HADOOP_HOME/tmp
echo "$avatarnode1IP $avatarnode1Name" >> $HADOOP_HOME/tmp

scp $HADOOP_HOME/tmp $avatarnode0IP:$HADOOP_HOME/hosts
scp $HADOOP_HOME/tmp $avatarnode1IP:$HADOOP_HOME/hosts

cat $HADOOP_HOME/tmp

rm $HADOOP_HOME/tmp

ssh $avatarnode0IP  sudo chmod 777 $HADOOP_HOME/bin/config_hosts.sh
ssh $avatarnode0IP  $HADOOP_HOME/bin/config_hosts.sh

echo ssh $avatarnode1IP  $HADOOP_HOME/bin/config_hosts.sh
ssh $avatarnode1IP  sudo chmod 777 $HADOOP_HOME/bin/config_hosts.sh
ssh $avatarnode1IP  $HADOOP_HOME/bin/config_hosts.sh




sleep $second
echo
echo \************************************************************************************
echo \*    5. remote copy the compiled version  to avatardatanode \*
echo \************************************************************************************
echo
sleep $second
HOSTLIST="${HADOOP_HOME}/conf/slaves"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do

 echo $IP is installing
 ssh $IP  sudo chmod 777 $HADOOP_HOME/..
 ssh $IP mkdir $HADOOP_HOME
 #nohup scp -r $HADOOP_HOME/build/hadoop-0.20.1-dev $IP:$HADOOP_HOME/..
 ssh $IP mkdir /usr/local/hadoop
 ssh $IP mkdir /usr/local/hadoop/block
 ssh $IP mkdir /usr/local/tmp
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

 if  [ $mun -gt $1 ]; then
  break
 fi

 mun=`expr $mun + 1` 
done

sleep $second
echo
echo \************************************************************************************
echo \*    6. remote copy the compiled version  to client \*
echo \************************************************************************************
echo
sleep $second

HOSTLIST="${HADOOP_HOME}/conf/clients"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 echo $IP is installing
 ssh $IP mkdir $HADOOP_HOME
 #nohup scp -r $HADOOP_HOME/build/hadoop-0.20.1-dev $IP:$HADOOP_HOME/..
 
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


 #ssh $IP  cp $HADOOP_HOME/conf/core-site-client.xml  $HADOOP_HOME/conf/core-site.xml 
 if  [ $mun -gt $2 ]; then
  break
 fi

 mun=`expr $mun + 1` 
done



#!/usr/bin/env bash


bin=`dirname "$0"`
bin=`cd "$bin"; pwd`


#echo $0

#echo HADOOP_HOME=$HADOOP_HOME

. "$bin"/hadoop-config.sh

cmd=$1

HOSTLIST="${HADOOP_HOME}/conf/masters"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 avatarnode0IP=$IP
 fi
 if  [ $mun == 1  ] ;
 then
 standby=$IP
 fi

 mun=`expr $mun + 1` 
done
echo =============
#echo cmd=$cmd

#"$bin"/hadoop-daemon.sh --config $HADOOP_CONF_DIR stop avatar
ssh  192.168.1.9 $HADOOP_HOME/bin/hadoop dfsadmin -saveNamespace
ssh $HADOOP_SSH_OPTS 192.168.1.9 "cd ${HADOOP_HOME}/; ${HADOOP_HOME}/bin/hadoop --config ${HADOOP_HOME}/conf/ org.apache.hadoop.hdfs.AvatarShell -zero -setAvatar primary" \
2>&1 | sed "s/^/192.168.1.9: /" &


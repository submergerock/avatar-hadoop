#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Stop hadoop DFS daemons.  Run this on master node.

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/hadoop-config.sh

cmd=$1

#echo cmd=$cmd

#"$bin"/hadoop-daemon.sh --config $HADOOP_CONF_DIR stop avatar



if [ "$cmd" == "-primary" ];then
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatar 
fi

if [ "$cmd" == "-standby" ];then
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatar -standby
fi

if [ "$cmd" == "-datanode" ];then
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatardatanode
fi

if [ "$cmd" == "" ];then
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatar 
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatar -standby
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatardatanode
fi

sleep 20

HOSTLIST="${HADOOP_HOME}/conf/masters"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 avatarnode0IP=$IP
 avatarnode0=$(ssh $avatarnode0IP /home/wl826214/jdk1.6.0_24/bin/jps | grep "AvatarNode")
 if [ -z "$avatarnode0" ] ;
then
  echo $avatarnode0IP AvatarNode has stoped!!!
 fi

 if [ -n "$avatarnode0" ] ;
then
  echo $avatarnode0IP AvatarNode failed to stop!!!
 fi
fi


 if  [ $mun == 1  ] ;
 then
 avatarnode1IP=$IP
 avatarnode1=$(ssh $avatarnode1IP /home/wl826214/jdk1.6.0_24/bin/jps | grep "AvatarNode")
 if [ -z "$avatarnode1" ];
then
  echo $avatarnode1IP AvatarNode has stoped!!!
 fi

 if [ -n "$avatarnode1" ];
then
  echo $avatarnode1IP AvatarNode failed to stop!!!
 fi
 fi

 mun=`expr $mun + 1` 
done

HOSTLIST="${HADOOP_HOME}/conf/slaves"
mun=0
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 
 avatarnode0=$(ssh $IP /home/wl826214/jdk1.6.0_24/bin/jps | grep "AvatarDataNode")
 if [ -z "$avatarnode0" ];
then
  echo $IP AvatarDataNode has stoped!!!
 fi

 if [ -n "$avatarnode0" ];
then
  echo $P AvatarDataNode failed to stop!!!
 fi



done





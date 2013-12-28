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

#echo cmd=$cmd

#"$bin"/hadoop-daemon.sh --config $HADOOP_CONF_DIR stop avatar

ssh $HADOOP_SSH_OPTS $standby "cd ${HADOOP_HOME}/; ${HADOOP_HOME}/bin/hadoop --config ${HADOOP_HOME}/conf/ org.apache.hadoop.hdfs.AvatarShell -one -setAvatar primary" \
2>&1 | sed "s/^/$standby: /" &


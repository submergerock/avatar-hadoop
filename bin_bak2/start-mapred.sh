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


# Start hadoop map reduce daemons.  Run this on master node.

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/hadoop-config.sh

# start mapred daemons
# start jobtracker first to minimize connection errors at startup
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR start jobtracker
sleep 10
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR start tasktracker
#"$bin"/start-raidnode-remote.sh --config $HADOOP_CONF_DIR
#"$bin"/start-hmon-remote.sh --config $HADOOP_CONF_DIR

sleep 10

HOSTLIST="${HADOOP_HOME}/conf/masters"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 
 jobtracker=$IP
 avatarnode0=$(ssh $jobtracker /root/jdk1.6.0_25/bin/jps | grep "JobTracker")
 if [ -z "$avatarnode0" ] ;
then
  echo $jobtracker jobtracker failed to start!!!
 fi

 if [ -n "$avatarnode0" ] ;
then
  echo $jobtracker jobtracker has started!!!
 fi


done





HOSTLIST="${HADOOP_HOME}/conf/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 
 avatarnode0=$(ssh $IP /root/jdk1.6.0_25/bin/jps | grep "TaskTracker")
 if [ -z "$avatarnode0" ] ;
then
  echo $IP tasktracker failed to start!!!
 fi

 if [ -n "$avatarnode0" ] ;
then
  echo $IP tasktracker has started!!!
 fi



done
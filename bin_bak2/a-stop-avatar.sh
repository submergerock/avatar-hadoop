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

#echo cmd=$cmd

#"$bin"/hadoop-daemon.sh --config $HADOOP_CONF_DIR stop avatar



if [ "$cmd" == "-zero" ];then
"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR stop avatar 
fi

if [ "$cmd" == "-one" ];then
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
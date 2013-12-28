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


# Run a shell command on all slave hosts.
#
# Environment Variables
#
#   HADOOP_SLAVES    File naming remote hosts.
#     Default is ${HADOOP_CONF_DIR}/slaves.
#   HADOOP_CONF_DIR  Alternate conf dir. Default is ${HADOOP_HOME}/conf.
#   HADOOP_SLAVE_SLEEP Seconds to sleep between spawning remote commands.
#   HADOOP_SSH_OPTS Options passed to ssh when running remote commands.
##

usage="Usage: slaves.sh [--config confdir] command..."

# if no args specified, show usage

if [ $# -le 0 ]; then
  echo $usage
  exit 1
fi

mun=$#
#echo $cmd
#echo "==================$@=========================="
#echo $@
#echo "==================$@=========================="


start=`echo $@|grep -ri  "start"`
sb=`echo $@|grep -ri  "standby"`
avatardatanode=`echo $@|grep -ri  "avatardatanode"`
stop=`echo $@|grep -ri  "stop"`
zero=`echo $@|grep -ri  "zero"`
one=`echo $@|grep -ri  "one"`
sync=`echo $@|grep -ri  "sync"`
avatar=`echo $@|grep -ri  " avatar "`


jobtracker=`echo $@|grep -ri  "jobtracker"`
tasktracker=`echo $@|grep -ri  "tasktracker"`

#echo "==================avatardatanode=========================="
#echo avatardatanode=$avatardatanode
#echo "==================avatardatanode=========================="



#echo "==================avatar=========================="
#echo standby=$sb
#echo "==================avatar=========================="


#echo "$@"

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/hadoop-config.sh

# If the slaves file is specified in the command line,
# then it takes precedence over the definition in 
# hadoop-env.sh. Save it here.

#################################avatarnode0 start as primary#########################################
if [ -n "$avatar" -a -z "$sb" -a -n "$start" -a -n "$zero" ];
then

#echo $cmd
echo "==================avatarnode0 start as primary=========================="
HOSTLIST="${HADOOP_CONF_DIR}/masters"

mun=0
for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 fi
 #echo $mun
 mun=`expr $mun + 1`
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done

fi
#################################avatarnode0 start as standby#########################################
if [ -n "$avatar" -a -n "$sb" -a -n "$start" -a -n "$zero" ];
then

#echo $cmd
echo "==================avatarnode0 start as standby=========================="
HOSTLIST="${HADOOP_CONF_DIR}/masters"

mun=0
for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 0  ] ;
 then
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 fi
 #echo $mun
 mun=`expr $mun + 1`
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done

fi
#################################avatarnode1 start as primary##################################################
if [ -n "$avatar" -a -z "$sb" -a -n "$start" -a -n "$one" ];
then

#echo $cmd
echo "==================savatarnode1 start as primary=========================="
HOSTLIST="${HADOOP_CONF_DIR}/masters"

mun=0
for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 1  ] ;
 then
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 fi
 #echo $mun
 mun=`expr $mun + 1`
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done

fi
#################################avatarnode1 start as standby##################################################
if [ -n "$avatar" -a -n "$sb" -a -n "$start" -a -n "$one" ];
then

#echo $cmd
echo "==================avatarnode1 start as standby=========================="
HOSTLIST="${HADOOP_CONF_DIR}/masters"

mun=0
for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 if  [ $mun == 1  ] ;
 then
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 fi
 #echo $mun
 mun=`expr $mun + 1`
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done

fi
###################################avatardatanode start/stop############################################
if [ "$avatardatanode" != "" ];
then

if [ "$start" != "" ]; then
echo "==================avatardatanode starting=========================="
fi

if [ "$stop" != "" ]; then
echo "==================avatardatanode stopping=========================="
fi

HOSTLIST=$HADOOP_SLAVES
if [ -f "${HADOOP_CONF_DIR}/hadoop-env.sh" ]; then
  . "${HADOOP_CONF_DIR}/hadoop-env.sh"
fi

if [ "$HOSTLIST" = "" ]; then
  if [ "$HADOOP_SLAVES" = "" ]; then
    export HOSTLIST="${HADOOP_CONF_DIR}/slaves"
  else
    export HOSTLIST="${HADOOP_SLAVES}"
  fi
fi



for slave in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 ssh $HADOOP_SSH_OPTS $slave $"${@// /\\ }" \
   2>&1 | sed "s/^/$slave: /" &
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done


fi

#################################avatar primary stop############################################
if [ -n "$avatar" -a -z "$sb" -a -n "$stop" ];
then


echo "==================primary stopping=========================="


HOSTLIST="${HADOOP_CONF_DIR}/masters"

mun=0
for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do

 if  [ $mun == 0  ] ;
 then
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 fi
 #echo $mun
 mun=`expr $mun + 1`
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done

fi
#################################avatar standby stop############################################
if [ -n "$avatar" -a -n "$sb" -a -n "$stop" ];
then


echo "==================standby stopping=========================="


HOSTLIST="${HADOOP_CONF_DIR}/masters"

mun=0
for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do

 if  [ $mun == 1  ] ;
 then
echo   "s/^/$standby: /"
#echo   $HADOOP_SSH_OPTS 
#echo  ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }"  2>&1 | sed "s/^/$standby: /" &

 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 fi
 #echo $mun
 mun=`expr $mun + 1`
 if [ "$HADOOP_SLAVE_SLEEP" != "" ]; then
   sleep $HADOOP_SLAVE_SLEEP
 fi
done

fi
################################# start jobtracker#########################################
if [ -n "$start" -a -n "$jobtracker" ];
then

#echo $cmd
echo "==================start jobtracker=========================="
HOSTLIST="${HADOOP_CONF_DIR}/masters"

for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do

 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &
 
done

fi

################################# start tasktracker#########################################
if [ -n "$start" -a -n "$tasktracker" ];
then

#echo $cmd
echo "==================start tasktracker=========================="
HOSTLIST="${HADOOP_CONF_DIR}/slaves"

for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &

done

fi
################################# stop jobtracker#########################################
if [ -n "$stop" -a -n "$jobtracker" ];
then

#echo $cmd
echo "==================stop jobtracker=========================="
HOSTLIST="${HADOOP_CONF_DIR}/masters"

for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
 
 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &

done

fi

################################# stop tasktracker#########################################
if [ -n "$stop" -a -n "$tasktracker" ];
then

echo "==================stop tasktracker=========================="
HOSTLIST="${HADOOP_CONF_DIR}/slaves"

for standby in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do

 ssh $HADOOP_SSH_OPTS $standby $"${@// /\\ }" \
   2>&1 | sed "s/^/$standby: /" &

done

fi

wait

#!/usr/bin/env bash
cp $HADOOP_HOME/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $HADOOP_HOME/lib/

HOSTLIST="${HADOOP_HOME}/conf_bak/masters"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo $IP
 scp $HADOOP_HOME/build/hadoop-0.20.1-dev-core.jar $IP:$HADOOP_HOME/
scp $HADOOP_HOME/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $IP:$HADOOP_HOME/lib/
done


HOSTLIST="${HADOOP_HOME}/conf_bak/slaves"

for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo $IP
 scp $HADOOP_HOME/build/hadoop-0.20.1-dev-core.jar $IP:$HADOOP_HOME/
scp $HADOOP_HOME/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $IP:$HADOOP_HOME/lib/
done

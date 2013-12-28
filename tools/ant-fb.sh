#!/usr/bin/env bash
#cd $HADOOP_HOME
cd /home/hadoop/avatar-hadoop/
#cp $HADOOP_HOME/conf/* $HADOOP_HOME/conf_bak/
#cp $HADOOP_HOME/bin/* $HADOOP_HOME/bin_bak/
ant -Djava5.home=$Java5Home  tar
#/usr/local/hadoop-0.20.1-dev-patch/tools/scp.sh
#cp $HADOOP_HOME/conf_bak/* $HADOOP_HOME/conf/
#cp $HADOOP_HOME/bin_bak/* $HADOOP_HOME/bin/

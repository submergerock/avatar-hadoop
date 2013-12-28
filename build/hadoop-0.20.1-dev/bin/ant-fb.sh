#!/usr/bin/env bash
cd $HADOOP_HOME
ant -Djava5.home=$Java5Home compile tar
./scp.sh
cp $HADOOP_HOME/conf_bak/* $HADOOP_HOME/conf/

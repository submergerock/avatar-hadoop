#!/usr/bin/env bash
vmbd04=172.16.40.234
cp  /home/hadoop/avatar-hadoop/conf/hadoop-env.sh /home/hadoop/avatar-hadoop/conf_master/
cp  /home/hadoop/avatar-hadoop/conf/hadoop-env.sh /home/hadoop/avatar-hadoop/conf_standby/
cp  /home/hadoop/avatar-hadoop/conf/hadoop-env.sh /home/hadoop/avatar-hadoop/conf_datanode/
######################
cp  /home/hadoop/avatar-hadoop/bin/hadoop /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/bin/            
###################### 
cp  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/lib/
ssh vmbd04 mkdir -p /home/hadoop/copy/avatar-hadoop/hadoop-0.20.1-dev
#scp -r /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-examples.jar /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/ivy /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/bin /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/conf /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-ant.jar /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-test.jar /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/webapps /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/contrib /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-core.jar /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-tools.jar /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/lib vmbd04:/home/hadoop/copy/avatar-hadoop/hadoop-0.20.1-dev/
#scp -r /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev vmbd04:/home/hadoop/copy/avatar-hadoop/
#scp -r /home/hadoop/avatar-hadoop/conf_master     vmbd04:/home/hadoop/copy/avatar-hadoop/hadoop-0.20.1-dev
#scp -r /home/hadoop/avatar-hadoop/conf_standby    vmbd04:/home/hadoop/copy/avatar-hadoop/hadoop-0.20.1-dev
#scp -r /home/hadoop/avatar-hadoop/conf_datanode   vmbd04:/home/hadoop/copy/avatar-hadoop/hadoop-0.20.1-dev
scp -r /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-test.jar  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-examples.jar  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/ivy  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/bin  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/conf  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-ant.jar  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-test.jar  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/webapps  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/contrib  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-core.jar  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/hadoop-0.20.1-dev-tools.jar  /home/hadoop/avatar-hadoop/build/hadoop-0.20.1-dev/lib  /home/hadoop/avatar-hadoop/conf_master  /home/hadoop/avatar-hadoop/conf_standby  /home/hadoop/avatar-hadoop/conf_datanode  vmbd04:/home/hadoop/copy/avatar-hadoop/hadoop-0.20.1-dev/





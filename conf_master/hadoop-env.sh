# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.  Required.
# export JAVA_HOME=/usr/lib/j2sdk1.5-sun
#export JAVA_HOME=/usr/java/jdk1.6.0_26
source /home/hadoop/.bashrc_avatar

# Extra Java CLASSPATH elements.  Optional.
# export HADOOP_CLASSPATH=

# The maximum amount of heap to use, in MB. Default is 1000.
# export HADOOP_HEAPSIZE=2000

# Extra Java runtime options.  Empty by default.
# export HADOOP_OPTS=-server

export HADOOP_LOG_DIR=/data02/hadooplog/avatar-hadoop
export HADOOP_OPTS="$HADOOP_OPTS"

# Command specific options appended to HADOOP_OPTS when specified
DATE=$(date +%Y%m%d%H%M%S)
HADOOP_NAMENODE_OPTS=" -Xms6000M -Xmx6000M -Xmn2000M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=128M -XX:MaxPermSize=128M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+DisableExplicitGC -XX:+UseParNewGC -XX:ParallelGCThreads=2 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:ErrorFile=$HADOOP_LOG_DIR/namenode-crash-$DATE.log -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-namenode-$DATE.log "

#HADOOP_NAMENODE_OPTS=" -server -Xms6000M -Xmx6000M -Xmn2000M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=128M -XX:MaxPermSize=128M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-namenode-$DATE.log "
#export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"

HADOOP_SECONDARYNAMENODE_OPTS=" -server -Xms2000M -Xmx2000M -Xmn750M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=128M -XX:MaxPermSize=128M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+DisableExplicitGC -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -XX:+HeapDumpOnOutOfMemoryError -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-secondnode-$DATE.log "
#export HADOOP_SECONDARYNAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"

#HADOOP_DATANODE_OPTS=" -server -Xms3000M -Xmx3000M -Xmn1000M -Xss128k -XX:MaxDirectMemorySize=512M -XX:PermSize=128M -XX:MaxPermSize=128M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+DisableExplicitGC -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-datanode-$DATE.log "
#HADOOP_DATANODE_OPTS=" -server -Xms3000M -Xmx3000M -Xmn1000M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=64M -XX:MaxPermSize=64M -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=5 -Xnoclassgc -XX:+DisableExplicitGC -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStopedTime -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-datanode-$DATE.log "

HADOOP_DATANODE_OPTS=" -server -Xms3000M -Xmx3000M -Xmn1000M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=32M -XX:MaxPermSize=32M -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=5 -Xnoclassgc  -XX:+UseParallelGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=300 -XX:ParallelGCThreads=2 -XX:+UseParallelOldGC -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HADOOP_LOG_DIR -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-datanode-$DATE.log "

#export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
#export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"

HADOOP_JOBTRACKER_OPTS=" -server -Xms1000M -Xmx1000M -Xmn150M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=128M -XX:MaxPermSize=128M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -XX:+HeapDumpOnOutOfMemoryError -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-jobtracker-$DATE.log "
#export HADOOP_JOBTRACKER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"

#HADOOP_TASKTRACKER_OPTS=" -server -Xms512M -Xmx512M -Xmn100M -Xss160k -XX:MaxDirectMemorySize=128M -XX:PermSize=64M -XX:MaxPermSize=64M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+DisableExplicitGC -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCApplicationStopedTime -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-tasktracker-$DATE.log "

HADOOP_TASKTRACKER_OPTS=" -server -Xms512M -Xmx512M -Xmn160M -Xss160k -XX:MaxDirectMemorySize=128M -XX:PermSize=32M -XX:MaxPermSize=32M  -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=5 -Xnoclassgc  -XX:+UseParallelGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=300 -XX:ParallelGCThreads=2 -XX:+UseParallelOldGC -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HADOOP_LOG_DIR  -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-tasktracker-$DATE.log "

#export HADOOP_TASKTRACKER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_TASKTRACKER_OPTS"

# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
#HADOOP_CLIENT_OPTS=" -Xms512M -Xmx512M -Xmn100M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=32M -XX:MaxPermSize=32M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HADOOP_LOG_DIR -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStopedTime -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-client.log "

HADOOP_CLIENT_OPTS=" -Xms512M -Xmx2048M -Xmn160M -Xss160k -XX:MaxDirectMemorySize=512M -XX:PermSize=32M -XX:MaxPermSize=32M -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=5 -Xnoclassgc  -XX:+UseParallelGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=2 -XX:+UseParallelOldGC -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -XX:+HeapDumpOnOutOfMemoryError -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-client.log "

#APP_SERVER_OPTS=" -server -Xms1000M -Xmx1000M -Xmn150M -Xss256k -XX:MaxDirectMemorySize=64M -XX:PermSize=64M -XX:MaxPermSize=64M -XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0 -Xnoclassgc -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=2 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStopedTime -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-app-$DATE.log "

APP_SERVER_OPTS=" -server -Xms1000M -Xmx1000M -Xmn300M -Xss160k -XX:MaxDirectMemorySize=128M -XX:PermSize=32M -XX:MaxPermSize=32M  -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=5 -Xnoclassgc  -XX:+UseParallelGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=300 -XX:ParallelGCThreads=2 -XX:+UseParallelOldGC -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HADOOP_LOG_DIR  -XX:+PrintHeapAtGC -Xloggc:$HADOOP_LOG_DIR/hadoop-smp-gc-app-$DATE.log "


export HADOOP_NAMENODE_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"
export HADOOP_SECONDARYNAMENODE_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
export HADOOP_BALANCER_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"
export HADOOP_CLIENT_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $HADOOP_CLIENT_OPTS"
export APP_SERVER_OPTS="-Djava.net.preferIPv4Stack=true -Dcom.sun.management.jmxremote $APP_SERVER_OPTS"
# export HADOOP_TASKTRACKER_OPTS=
# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
# export HADOOP_CLIENT_OPTS

# Extra ssh options.  Empty by default.
# export HADOOP_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"

# Where log files are stored.  $HADOOP_HOME/logs by default.
# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs


# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1

# The directory where pid files are stored. /tmp by default.
# export HADOOP_PID_DIR=/var/hadoop/pids
export HADOOP_PID_DIR=/home/hadoop/avatar-hadoop/pids

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10


#! /bin/sh

AvatarNode=$(/home/wl826214/jdk1.6.0_24/bin/jps | grep "AvatarNode")
if [ -n "$AvatarNode" ];
then
	Primary=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop org.apache.hadoop.hdfs.AvatarShell -D fs.default.name=hdfs://192.168.1.11:9000  -showAvatar | grep "Primary")	
fi


while [ -z "$Primary" ]
      do

AvatarNode=$(/home/wl826214/jdk1.6.0_24/bin/jps | grep "AvatarNode")
if [ -n "$AvatarNode" ];
then
	Primary=$(/usr/local/hadoop-0.20.1-dev/bin/hadoop org.apache.hadoop.hdfs.AvatarShell -D fs.default.name=hdfs://192.168.1.11:9000  -showAvatar | grep "Primary")
	
fi
 
sleep 1
done

echo "826214" | sudo -S /sbin/ip addr add 192.168.1.9/24 dev eth0
#nohup /usr/local/hadoop-0.20.1-dev/bin/hadoop jobtracker &

#echo "826214" | sudo -S /sbin/ip addr add 192.168.1.9/24 dev eth0

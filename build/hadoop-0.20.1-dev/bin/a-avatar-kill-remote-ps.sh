#!/usr/bin/env bash

if [ $# -le 1 ]; then
  echo "a-avatar-kill-Avatarnode.sh  <HostIP> <psName> "
  exit 1
fi
echo


HostIP=$1
psName=$2

echo HostIP = $HostIP
echo psName = $psName
echo
sleep 2
echo \******************************************
echo \*       kill  $psName  on  $HostIP  \*
echo \******************************************
echo
sleep 2


ssh $HostIP ps an | grep "$psName" | awk '{print $1}' >> /home/wl826214/hadoop-0.20.1-dev/tmp

#sleep 5
#echo ---111----
cat /home/wl826214/hadoop-0.20.1-dev/tmp
#echo ---222----
#sleep 2
#echo ---333----
for psNum in `cat /home/wl826214/hadoop-0.20.1-dev/tmp`; do   
   echo $psNum
   ssh $HostIP kill -9 $psNum
done
#echo ---444----
#sleep 5

#echo $psNO

sleep 2



rm /home/wl826214/hadoop-0.20.1-dev/tmp


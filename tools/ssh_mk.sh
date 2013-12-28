#!/usr/bin/env bash

if [ $# -le 0 ]; then
  echo "ssh_copy.sh  <password>"
  exit 1
fi

username=$(whoami)

root=$(echo `whoami` | grep "root")

if [ -n "$root" ]; then
userpath=/root
else
userpath=/home/$username
fi
echo HADOOP_HOME is ${HADOOP_HOME}

echo
echo
echo \************************************************************************************
echo \*    1.   rm -r -f $userpath/.ssh/* \*
echo \************************************************************************************
echo
sleep 1
rm -r -f $userpath/.ssh/*


echo
echo \************************************************************************************
echo \*    2.   ssh-keygen -t dsa -P '' -f $userpath/.ssh/id_dsa \*
echo \************************************************************************************
echo
sleep 1
ssh-keygen -t dsa -P '' -f $userpath/.ssh/id_dsa

echo
echo \************************************************************************************
echo \*    3.   cat $userpath/.ssh/id_dsa.pub >> $userpath/.ssh/authorized_keys \*
echo \************************************************************************************
echo
sleep 1
 cat $userpath/.ssh/id_dsa.pub >> $userpath/.ssh/authorized_keys

echo
echo \************************************************************************************
echo \*    4.   chmod 600 $userpath/.ssh/authorized_keys \*
echo \************************************************************************************
echo
sleep 1
 chmod 600 $userpath/.ssh/authorized_keys


echo
echo \************************************************************************************
echo \*    5.   ssh localhost hostname \*
echo \************************************************************************************
echo
sleep 1
${HADOOP_HOME}/tools/ssh_localhost.sh $1

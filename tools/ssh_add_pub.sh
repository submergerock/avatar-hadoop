#!/usr/bin/env bash

username=$(whoami)

root=$(echo `whoami` | grep "root")

echo username:$username
echo root:$root

if [ -n "$root" ]; then
userpath=/root
else
userpath=/home/$username
fi


echo
echo \************************************************************************************
echo \*       cat $userpath/.ssh/*.pub >> $userpath/.ssh/authorized_keys \*
echo \************************************************************************************
echo
sleep 1


for IP in `ls $userpath/.ssh/*.pub | sed  -n "/pub/"p`; do
 echo $IP
 cat $IP >> $userpath/.ssh/authorized_keys
done


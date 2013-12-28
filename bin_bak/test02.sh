#!/usr/bin/env bash

if [ $# -le 3 ]; then
  echo "test02_S_to_P.sh  <avatarnode0Local> <avatarnode0NFS> <avatarnode1Local> <avatarnode1NFS>"
  exit 1
fi
echo



#avatarnode0IP=$1
avatarnode0Local=$1
avatarnode0NFS=$2

#avatarnode1IP=$4
avatarnode1Local=$3
avatarnode1NFS=$4
echo avatarnode0IP = $avatarnode0IP
echo avatarnode0Local = $avatarnode0Local
echo avatarnode0NFS = $avatarnode0NFS
echo avatarnode1IP = $avatarnode1IP
echo avatarnode1Local = $avatarnode1Local
echo avatarnode1NFS = $avatarnode1NFS
echo HADOOP_HOME = $HADOOP_HOME
echo
sleep 5
echo \******************************************
echo \*    1.old node without sync \*
echo \******************************************
echo
sleep 5
./test02_S_to_P_oldnode_without_sync.sh $avatarnode0Local $avatarnode0NFS $avatarnode1Local $avatarnode1NFS

echo
sleep 5
echo \******************************************
echo \*    2.old node with sync \*
echo \******************************************
echo
sleep 5
./test02_S_to_P_oldnode_with_sync.sh $avatarnode0Local $avatarnode0NFS $avatarnode1Local $avatarnode1NFS

echo
sleep 5
echo \******************************************
echo \*    3.new node without sync \*
echo \******************************************
echo
sleep 5
./test02_S_to_P_newnode_without_sync.sh $avatarnode0Local $avatarnode0NFS $avatarnode1Local $avatarnode1NFS


echo
sleep 5
echo \******************************************
echo \*    4.new node with sync \*
echo \******************************************
echo
sleep 5
./test02_S_to_P_newnode_with_sync.sh $avatarnode0Local $avatarnode0NFS $avatarnode1Local $avatarnode1NFS


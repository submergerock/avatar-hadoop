#!/usr/bin/env bash

if [ $# -le 1 ]; then
  echo "test06_mr.sh  <times of run> <second>"
  exit 1
fi


num=$1
sec=$2
n=0
while [ $num -gt 0 ]
        do
  echo start MR$n job 
  n=`expr  $n  +  1`
  num=`expr  $num  -  1`
  nohup /usr/local/hadoop-0.20.1-dev/bin/hadoop jar matrixMulti.jar matrixControl &
  sleep $sec
done
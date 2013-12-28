#!/usr/bin/env bash

if [ $# -le 0 ]; then
  echo "changMac.sh <netcard>"
  exit 1
fi
echo

mac=$(ifconfig $1 | grep $1 | awk '{print $5}')
netcard=$1
mac="HWADDR=$mac"
echo netcard=$netcard
echo mac=$mac
###########create the sed file to change /etc/sysconfig/network-scripts/ifcfg-eth0####
echo "#!/bin/sed -f" >> /usr/local/change.sed
echo "# change.sed" >> /usr/local/change.sed
echo "/HWADDR/ c\\" >> /usr/local/change.sed
echo $mac >> /usr/local/change.sed
echo "826214" | sudo -S chmod 777 /usr/local/change.sed

/usr/local/change.sed /etc/sysconfig/network-scripts/ifcfg-eth0 >> /usr/local/tmp.t
echo "826214" | sudo -S mv /usr/local/tmp.t /etc/sysconfig/network-scripts/ifcfg-eth0 

rm /usr/local/change.sed

echo "826214" | sudo -S service network restart

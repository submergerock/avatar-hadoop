#!/usr/bin/env bash
cp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar /usr/local/hadoop-0.20.1-dev-patch/lib/
cp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/raid/hadoop-0.20.1-dev-raid.jar /usr/local/hadoop-0.20.1-dev-patch/lib/
cp /usr/local/hadoop-0.20.1-dev-patch/build/hadoop-0.20.1-dev-core.jar /usr/local/hadoop-0.20.1-dev-patch/


HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/masters"
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo $IP
 scp /usr/local/hadoop-0.20.1-dev-patch/build/hadoop-0.20.1-dev-core.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/
scp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
scp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/raid/hadoop-0.20.1-dev-raid.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
scp /usr/local/hadoop-0.20.1-dev-patch/lib/CDR.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
done

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/slaves"
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo $IP
 scp /usr/local/hadoop-0.20.1-dev-patch/build/hadoop-0.20.1-dev-core.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/
scp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
scp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/raid/hadoop-0.20.1-dev-raid.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
scp /usr/local/hadoop-0.20.1-dev-patch/lib/CDR.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
done

HOSTLIST="/usr/local/hadoop-0.20.1-dev-patch/conf_bak/clients"
for IP in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
echo $IP
 scp /usr/local/hadoop-0.20.1-dev-patch/build/hadoop-0.20.1-dev-core.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/
scp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/highavailability/hadoop-0.20.1-dev-highavailability.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
scp /usr/local/hadoop-0.20.1-dev-patch/build/contrib/raid/hadoop-0.20.1-dev-raid.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
scp /usr/local/hadoop-0.20.1-dev-patch/lib/CDR.jar $IP:/usr/local/hadoop-0.20.1-dev-patch/lib/
done

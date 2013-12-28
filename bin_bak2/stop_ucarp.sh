#!/usr/bin/env bash
sleep 1

PID=$(ssh 192.168.1.11 ps an | grep "ucarp --interface" | awk '{print $1}' | head -n1)

ssh 192.168.1.11 echo "826214" | sudo -S kill $PID
sleep 1


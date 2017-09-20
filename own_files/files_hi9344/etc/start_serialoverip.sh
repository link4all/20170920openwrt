#!/bin/sh

# Start data forwarding between UDP and Serial.
# If an instance is already running, then exit.
# The starting timeout is 30s.
timeout=30
br_ip=`ifconfig |grep "Bcast" |cut -d ":" -f2 | cut -d" " -f1`
while [ $timeout -ne 0 ]
do
if [ `ps | grep serialoverip | wc -l` -eq 2 ]
then
break
fi
if [ `ifconfig br-lan | grep $br_ip | wc -l` -eq 1 ]
then
stty -F /dev/ttyS0 115200
serialoverip -s "$br_ip" 2018 -d /dev/ttyS0 115200-8N1 &
break
fi
let timeout=$timeout-1
sleep 1
done

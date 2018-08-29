#!/bin/sh
wifidog=$(ps | grep -c mon_loop.sh)
if [ $wifidog = 2 ];then
echo "ok"
else
echo "not"
fi


grep -q mon0 /proc/net/dev || /usr/sbin/iw phy phy0 interface add mon0 type monitor
ifconfig mon0 up

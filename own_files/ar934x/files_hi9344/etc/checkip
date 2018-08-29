#!/bin/sh

ifconfig wlan0 |grep 'inet addr' |cut -d: -f2 | cut -d " " -f1 >/tmp/wwanip
udp=$(ps | grep -c udp_client)
if [ $udp -lt 2 ];then
/bin/udp_client& >/dev/null
else
echo "udp_client already run!"
fi

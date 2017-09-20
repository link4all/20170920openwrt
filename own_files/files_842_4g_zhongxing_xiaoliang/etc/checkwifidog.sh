#!/bin/sh
if [ 1 = $(uci get wifidog.@wifidog[0].deamo_enable) ] ;then 
{ 
echo "deamo enabled"
wifidog=$(ps | grep -c /usr/bin/wifidog)
if [ $wifidog = 2 ];then
echo "ok"
else
/usr/bin/wifidog start >/dev/null
fi
}
else 
{
 echo "deamo not enabled"
 exit 0
}
fi

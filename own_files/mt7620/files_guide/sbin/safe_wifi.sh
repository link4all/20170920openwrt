#!/bin/sh

enable=`uci get safe_wifi.main.useing`

echo "enable=$enable"
if [ "$enable" != "1" ];then
	sed '/wifi/'d /etc/crontabs/root > /root/root
	cp /root/root /etc/crontabs/root
	/etc/init.d/cron restart &
	exit 0;
fi

s_hour=`uci get safe_wifi.main.start_hour`
s_min=`uci get safe_wifi.main.start_min`
e_hour=`uci get safe_wifi.main.stop_hour`
e_min=`uci get safe_wifi.main.stop_min`
echo "$s_hour:$s_min wifi up,$e_hour:$e_min wifi down!"
sed '/wifi/'d /etc/crontabs/root > /root/root
cp /root/root /etc/crontabs/root
start_cron="$s_min $s_hour * * * /etc/init.d/network restart"
stop_cron="$e_min $e_hour * * * ifconfig ra0 down"
echo "$start_cron" >> /etc/crontabs/root
echo "$stop_cron" >> /etc/crontabs/root

/etc/init.d/cron restart &
exit 0

#!/bin/sh

if [ ! -d /sys/class/gpio/gpio1 ];then
echo 1 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio1/direction
echo 1 > /sys/class/gpio/gpio1/value
sleep 2
echo 0 > /sys/class/gpio/gpio1/value
#sleep 5
#uci set network.4g=interface
#uci set network.4g.proto=dhcp
#uci set network.4g.ifname=eth2
#uci commit network
#uci set firewall.@zone[1].network="wan wan6 4g"
#uci commit firewall
#sleep 10
#quectel-CM -s 3gnet -f /tmp/4g.log&

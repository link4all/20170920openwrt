#!/bin/sh

if [ ! -d /sys/class/gpio/gpio15 ];then
echo 15 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio15/direction
echo 0 > /sys/class/gpio/gpio15/value
sleep 1
echo 1 > /sys/class/gpio/gpio15/value

# while true
# do 
#  if ls /dev/tty[U,A][S,C][B,M]* > /dev/null 2>&1 ;then
#  #echo "modem ready"
#  break
#  fi
#  sleep 1
# done

# uci set network.4g.proto='dhcp'
# uci set network.4g.ifname='eth2'
# uci set 4g.modem.device="/dev/ttyUSB2"

# if cat /sys/kernel/debug/usb/devices |grep "Vendor=1519 ProdID=0020 "  > /dev/null 2>&1;then
#     uci set 4g.modem.device="/dev/ttyACM3"
#     uci set network.4g.proto='3g'
#     uci set network.4g.device='/dev/ttyACM0'
#     uci set network.4g.apn="3gnet"
#     uci del network.4g.ifname

# fi
# if cat /sys/kernel/debug/usb/devices |grep "Vendor=8087 ProdID=095a" > /dev/null 2>&1;then
#     uci set 4g.modem.device="/dev/ttyACM2"
#     uci set network.4g.proto='3g'
#     uci set network.4g.device='/dev/ttyACM0'
#     uci set network.4g.apn="3gnet"
#     uci del network.4g.ifname
# fi
#     uci commit network
#     uci commit 4g



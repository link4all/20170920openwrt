#!/bin/sh

sig_dip(){
modem_tty=`uci get 4g.modem.device`
sig=`gcom -d  ${modem_tty} -s /etc/gcom/getstrength.gcom  |grep  "," |cut -d: -f2|cut -d, -f1 `
if [ $sig -lt 18 -a $sig -gt 0 ];then
echo 0  > /sys/class/leds/liwei\:sig1/brightness
echo 1  > /sys/class/leds/liwei\:sig2/brightness
elif [ $sig -ge 18 -a $sig -le 31 ];then
echo 1  > /sys/class/leds/liwei\:sig1/brightness
echo 0  > /sys/class/leds/liwei\:sig2/brightness
else 
echo 1 > /sys/class/leds/liwei\:sig1/brightness
echo 1  > /sys/class/leds/liwei\:sig2/brightness
fi
}

    modeminfo=`cat /etc/modules.d/AutoProbe-usb-net-gobinet`
if [ -e /dev/ttyUSB3 ];then
    if gcom -d  /dev/ttyUSB3 -s /etc/gcom/getcardinfo.gcom  |grep -ir quect ;then
      if [ ! "$modeminfo" = "gobinet_yy.ko" ];then
      echo "gobinet_yy.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
      reboot
      fi
    elif gcom -d  /dev/ttyUSB3 -s /etc/gcom/getcardinfo.gcom  |grep -ir meig ;then
      if [ ! "$modeminfo" = "gobinet_fg.ko" ];then
      echo "gobinet_fg.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
      reboot
      fi
    elif gcom -d  /dev/ttyUSB3 -s /etc/gcom/getcardinfo.gcom  |grep -ir longs ;then
      if [ ! "$modeminfo" = "gobinet_ls.ko" ];then
      echo "gobinet_ls.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
      reboot
      fi
    else
      echo "gobinet_fg.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
    fi
fi

sig_dip
while true
do
sig_dip
sleep 60
done
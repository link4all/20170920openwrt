#!/bin/sh

sig_dip(){
modem_tty=`uci get 4g.modem.device`
sig=`gcom -d  ${modem_tty} -s /etc/gcom/getstrength.gcom  |grep  "," |cut -d' ' -f2|cut -d, -f1 `
if [ $sig -le 31 -a $sig -ge 24 ];then
 echo timer >  /sys/class/leds/tp-link\:green\:wlan/trigger
 echo 1000 > /sys/class/leds/tp-link\:green\:wlan/delay_on
 echo 0 > /sys/class/leds/tp-link\:green\:wlan/delay_off
elif [ $sig -lt 24 -a $sig -ge 16 ];then
 echo timer >  /sys/class/leds/tp-link\:green\:wlan/trigger
 echo 50 > /sys/class/leds/tp-link\:green\:wlan/delay_on
 echo 50 > /sys/class/leds/tp-link\:green\:wlan/delay_off
elif [ $sig -lt 16 -a $sig -le 5 ];then
 echo timer >  /sys/class/leds/tp-link\:green\:wlan/trigger
 echo 500 > /sys/class/leds/tp-link\:green\:wlan/delay_on
 echo 500 > /sys/class/leds/tp-link\:green\:wlan/delay_off
else 
 echo timer >  /sys/class/leds/tp-link\:green\:wlan/trigger
 echo 0 > /sys/class/leds/tp-link\:green\:wlan/delay_on
 echo 1000 > /sys/class/leds/tp-link\:green\:wlan/delay_off
fi
}



sig_dip
while true
do
sig_dip
sleep 60
done
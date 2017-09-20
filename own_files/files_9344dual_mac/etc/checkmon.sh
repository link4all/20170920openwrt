#!/bin/sh
wifidog=$(ps | grep -c mon_loop.sh)
if [ $wifidog = 2 ];then
echo "ok"
else
#mon_loop.sh &
echo "not ok"
fi

grep -q mon0 /proc/net/dev || /usr/sbin/iw phy phy0 interface add mon0 type monitor
ifconfig mon0 up

grep -q mon1 /proc/net/dev || /usr/sbin/iw phy phy1 interface add mon1 type monitor
ifconfig mon1 up

#check 4g modem
 if ping www.baidu.com -c 5 | grep -c "64 bytes from" ; then  
    {
      echo "Wan interface OK"
    }
   else
        {
       echo "wan not ok"
      echo 0 > /sys/class/gpio/gpio12/value
      sleep 10 
      echo 1 > /sys/class/gpio/gpio12/value
         } 
   fi 



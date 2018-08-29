#!/bin/sh

while true
do
    if [ `ps |grep wifidog -c` -lt 2 ];then
    /etc/init.d/wifidog start
    else 
       echo "wifidog started!"
       if wdctl status  |grep "reachable: no"; then
       echo "Auth server not reachable, restart wifidog!"
       /etc/init.d/wifidog restart
       fi
    fi
    sleep 15

done
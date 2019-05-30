#!/bin/sh

if cat /sys/kernel/debug/usb/devices |grep -E "Vendor=8087 ProdID=095a |Vendor=1519 ProdID=0443" > /dev/null 2>&1;then
   
   ifdev=`uci get network.4g.ifname`
  
  while true
     do
            if ifconfig $ifdev|grep "inet addr:" |grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]" >/dev/null 2>&1;then 
            echo "$ifdev is up now"
            else
                device=`uci get 4g.modem.device`
                apn=`uci get config4g.4G.apn`
                username=`uci get config4g.4G.username`
                password=`uci get config4g.4G.password`
                auth=`uci get config4g.4G.auth`

                disconnect="AT+CGACT=0,1"
                setcgd="AT+CGDCONT=1,\"IP\",\"${apn}\""
                setdns="AT+XDNS=1,1"
                setauth="AT+MGAUTH=1,1,\"${username}\",\"${password}\",${auth:-0}"
                connect="AT+CGACT=1,1"
                setchannel="AT+XDATACHANNEL=1,1,\"/USBCDC/2\",\"/USBHS/NCM/0\",0"
                datamode="AT+CGDATA=\"M-RAW_IP\",1"
                

                COMMAND="$disconnect" gcom -d "$device" -s /etc/gcom/runcommand.gcom
                COMMAND="$setcgd" gcom -d "$device" -s /etc/gcom/runcommand.gcom
                COMMAND="$setdns" gcom -d "$device" -s /etc/gcom/runcommand.gcom
                COMMAND="$setauth" gcom -d "$device" -s /etc/gcom/runcommand.gcom
                COMMAND="$connect" gcom -d "$device" -s /etc/gcom/runcommand.gcom
                COMMAND="$setchannel" gcom -d "$device" -s /etc/gcom/runcommand.gcom
                COMMAND="$datamode" gcom -d "$device" -s /etc/gcom/runcommand.gcom

                gcom -d $device -s /etc/gcom/fibocom_getdnsip.gcom > /tmp/fibocomip

                dns1=$(cat /tmp/fibocomip |grep "\+XDNS:" |head -n 1 |cut -d, -f2 |tr -d '"')
                dns2=$(cat /tmp/fibocomip |grep "\+XDNS:" |head -n 1 |cut -d, -f3 |tr -d '"')
                lteip=$(cat /tmp/fibocomip |grep "\+CGDCONT:" |head -n 1 |cut -d, -f4 |tr -d '"')

                echo "nameserver $dns1" > /tmp/resolv.conf
                echo "nameserver $dns2" >> /tmp/resolv.conf

                ifconfig $ifdev $lteip netmask 255.255.255.255 -arp
                ip r add $lteip dev $ifdev
                ip r add 0.0.0.0/0 via $lteip dev $ifdev
            fi
        sleep 10
        done

fi

#!/bin/sh

device_at=`uci get 4g.modem.device`
#4g modem info：
rssi=$(gcom -d ${device_at} -s /etc/gcom/getstrength.gcom  |grep  "," |cut -d" " -f2|cut -d, -f1)
#rssi_percent=$(printf "%d%%\n" $((a*100/31)))
#rssi_percent=$a
#sim_status=$(gcom -d ${device_at} -s /etc/gcom/getsimstatus.gcom )
#roam=$(gcom -d ${device_at} -s /etc/gcom/checkregister.gcom )
#lac=$(gcom -d ${device_at} -s /etc/gcom/getlaccellid.gcom )
# model=$(gcom -d ${device_at} -s /etc/gcom/getcardinfo.gcom |head -n3|tail -n1|tr -d '\r')
if cat /sys/kernel/debug/usb/devices |grep -E "Vendor=8087 ProdID=095a |Vendor=1519 ProdID=0443" > /dev/null 2>&1;then
rev=`gcom -d "$device_at" -s /etc/gcom/fibocom_getcardinfo.gcom |awk '/\+CGMI:/' |cut -d '"' -f2 |tr [A-Z] [a-z]`
else
rev=$(gcom -d ${device_at} -s /etc/gcom/getcardinfo.gcom |grep -i rev |cut -d: -f2-|tr -d '\r')
fi
imei=$(gcom -d ${device_at} -s /etc/gcom/getimei.gcom)
imsi=$(gcom -d ${device_at} -s /etc/gcom/getimsi.gcom)
iccid=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/geticcid.gcom 2>/dev/null |awk '{print $2}' 2>/dev/null`
# if cat /sys/kernel/debug/usb/devices |grep "Vendor=1519 ProdID=0020\|Vendor=2c7c ProdID=0125";then
#     iccid=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/iccid_quectel.gcom 2>/dev/null |awk '{print $2}' 2>/dev/null`
# fi
if cat /sys/kernel/debug/usb/devices |grep "Vendor=8087 ProdID=095a";then
imei=$(gcom -d ${device_at} -s /etc/gcom/getimei.gcom|cut -d\" -f2)
rev="Fibocom-L850"
fi
if cat /sys/kernel/debug/usb/devices |grep "Vendor=05c6 ProdID=f601";then
    iccid=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/iccid_forge.gcom 2>/dev/null |awk '{print $2}' 2>/dev/null`
fi

if cat /sys/kernel/debug/usb/devices |grep "Vendor=1286 ProdID=4e3d";then
    iccid=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/iccid_air720.gcom 2>/dev/null |awk '{print $2}' 2>/dev/null`
fi

reg_net=$(gcom -d ${device_at} -s /etc/gcom/getregisterednetwork.gcom |cut -d: -f2- )

uci set 4g.modem.rssi="$rssi"
uci set 4g.modem.sim_status="$sim_status"
# uci set 4g.modem.model="$model"
uci set 4g.modem.rev="$rev"
uci set 4g.modem.imei="$imei"
uci set 4g.modem.imsi="$imsi"
uci set 4g.modem.iccid="$iccid"
#uci set 4g.modem.roam="$roam"
#uci set 4g.modem.lac="$lac"
uci set 4g.modem.reg_net="$reg_net"
uci commit 4g

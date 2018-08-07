#!/bin/sh

device_at=`uci get 4g.modem.device`
sleep 15
#4g modem info：
#a=$(gcom -d ${device_at} -s /etc/gcom/getstrength.gcom  |grep  "," |cut -d: -f2|cut -d, -f1)
#rssi_percent=$(printf "%d%%\n" $((a*100/31)))
#rssi_percent=$a
#sim_status=$(gcom -d ${device_at} -s /etc/gcom/getsimstatus.gcom )
model=$(gcom -d ${device_at} -s /etc/gcom/getcardinfo.gcom |head -n3|tail -n1|tr -d '\r')
rev=$(gcom -d ${device_at} -s /etc/gcom/getcardinfo.gcom |grep -i rev |cut -d: -f2-|tr -d '\r')
imei=$(gcom -d ${device_at} -s /etc/gcom/getimei.gcom)
imsi=$(gcom -d ${device_at} -s /etc/gcom/getimsi.gcom)
iccid=$(gcom -d ${device_at} -s /etc/gcom/iccid_forge.gcom|cut -d: -f2)
#roam=$(gcom -d ${device_at} -s /etc/gcom/checkregister.gcom )
#lac=$(gcom -d ${device_at} -s /etc/gcom/getlaccellid.gcom )
reg_net=$(gcom -d ${device_at} -s /etc/gcom/getregisterednetwork.gcom |cut -d: -f2- )

#uci set 4g.modem.rssi="$rssi_percent"
#uci set 4g.modem.sim_status="$sim_status"
uci set 4g.modem.model="$model"
uci set 4g.modem.rev="$rev"
uci set 4g.modem.imei="$imei"
uci set 4g.modem.imsi="$imsi"
uci set 4g.modem.iccid="$iccid"
#uci set 4g.modem.roam="$roam"
#uci set 4g.modem.lac="$lac"
uci set 4g.modem.reg_net="$reg_net"
uci commit 4g

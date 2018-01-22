#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_dialmode" = "pppd" ];then
uci set network.4g.proto='3g'
uci set network.4g.service="umts"
uci del network.4g.ifname
uci set network.4g.device="$FORM_device"
uci set network.4g.apn="$FORM_apn"
uci set network.4g.pincode="$FORM_pincode"
uci set network.4g.username="$FORM_username"
uci set network.4g.dialnumber="$FORM_dialnumber"
uci set network.4g.password="$FORM_password"
uci commit network
uci set config4g.@4G[0].enable="0"
uci commit config4g
uci set 4g.modem.device=$FORM_at
uci commit 4g
killall quectel-CM
/etc/init.d/config4g restart 
/etc/init.d/network restart 
else
  uci set network.4g.proto='dhcp'
  uci del network.4g.service
  uci set network.4g.ifname="eth2"
  uci del network.4g.device
  uci del network.4g.apn
  uci del network.4g.pincode
  uci del network.4g.username
  uci del network.4g.dialnumber
  uci del network.4g.password
  uci commit network
  uci set config4g.@4G[0].enable="1"
  uci set config4g.@4G[0].apn="$FORM_apn"
  uci set config4g.@4G[0].pincode="$FORM_pincode"
  uci set config4g.@4G[0].user="$FORM_username"
  uci set config4g.@4G[0].password="$FORM_password"
  uci commit config4g
  uci set 4g.modem.device=$FORM_at
  uci commit 4g
/etc/init.d/config4g restart 
  /etc/init.d/network restart
fi
i=0
i=0
while [ $i -lt 8 ]
do
[ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] || i=$(($i+1))
ipaddr=`ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
#echo $ipaddr
[ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] &&  break
done
echo "{"
echo "\"ipaddr\":\"$ipaddr\""
echo "}"

%>

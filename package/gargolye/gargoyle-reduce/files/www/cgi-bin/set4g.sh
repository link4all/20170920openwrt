#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""


uci set network.4g.device="$FORM_device"
uci set network.4g.apn="$FORM_apn"
uci set network.4g.pincode="$FORM_pincode"
uci set network.4g.username="$FORM_username"
uci set network.4g.password="$FORM_password"
uci commit network
/etc/init.d/network restart
i=0
i=0
while [ $i -lt 8 ]
do
[ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] || i=$(($i+1))
ipaddr=`ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
echo $ipaddr
[ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] &&  break
done

echo "{"
echo "\"ipaddr\":\"$ipaddr\""
echo "}"

%>

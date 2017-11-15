#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_wan_mode"x = "dhcp"x ];then
uci set network.wan.proto=dhcp
uci del network.wan.username
uci del network.wan.password
uci del network.wan.dns
uci del network.wan.gateway
uci del network.wan.ipaddr
uci del network.wan.netmask
echo "{"
echo "\"mode\":\"$FORM_wan_mode\""
echo "}"
fi

if [ "$FORM_wan_mode"x = "static"x ];then
uci set network.wan.proto=static
uci set network.wan.dns="$FORM_st_dns1 $FORM_st_dns2"
uci set network.wan.gateway="$FORM_st_gateway"
uci set network.wan.ipaddr="$FORM_wanip"
uci set network.wan.netmask="$FORM_st_mask"
uci del network.wan.username
uci del network.wan.password
echo "{"
echo "\"mode\":\"$FORM_wan_mode $FORM_dns1\","
echo "\"dns1\":\"$FORM_st_dns1\","
echo "\"dns2\":\"$FORM_st_dns2\","
echo "\"wanip\":\"$FORM_wanip\","
echo "\"gateway\":\"$FORM_st_gateway\","
echo "\"mask\":\"$FORM_st_mask\""
echo "}"
fi

if [ "$FORM_wan_mode"x = "pppoe"x ];then
uci set network.wan.proto=pppoe
uci set network.wan.username=$FORM_user
uci set network.wan.password=$FORM_passwd
uci del network.wan.dns
uci del network.wan.gateway
uci del network.wan.ipaddr
uci del network.wan.netmask
echo "{"
echo "\"mode\":\"$FORM_wan_mode\""
echo "}"
fi

if [ "$FORM_wan_mode"x = "bridge"x ];then
uci set dhcp.lan.ignore=1
uci del dhcp.lan.leasetime
uci del dhcp.lan.limit 
uci del dhcp.lan.start 
uci commit dhcp
/etc/init.d/dnsmasq restart
/etc/init.d/odhcpd restart

uci del network.wan.username
uci del network.wan.password
uci del network.wan.ipaddr
uci del network.wan.netmask
uci set network.wan.dns="$FORM_br_dns1 $FORM_br_dns1"
uci set network.wan.gateway="$FORM_br_gateway"
echo "{"
echo "\"mode\":\"$FORM_wan_mode\""
echo "}"
fi

uci commit network
/etc/init.d/network restart


%>

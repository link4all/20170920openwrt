#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

uci set wireless.stamode=wifi-iface
uci set wireless.@wifi-iface[1].ssid="$FORM_essid"
uci set wireless.@wifi-iface[1].key="$FORM_epwd"
uci set wireless.radio0.channel="$FORM_channel"
uci set wireless.@wifi-iface[1].encryption="$FORM_etype"
uci set wireless.@wifi-iface[1].bssid="$FORM_bssid"
uci set wireless.@wifi-iface[1].network="wwan"
uci set wireless.@wifi-iface[1].device="radio0"
uci set wireless.@wifi-iface[1].mode="sta"
uci set network.wwan=interface
uci set network.wwan.proto="dhcp"
uci commit wireless

echo "{"
echo "\"success\":\"ok\",\"enc\":\"$FORM_etype $FORM_essid $FORM_channel\""
echo "}"
/etc/init.d/network restart
%>

#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""


uci set network.lan.ipaddr="$FORM_lanip"
uci set network.lan.netmask="$FORM_mask"

echo "{"
echo "\"ipaddr\":\"$FORM_lanip\""
echo "}"

uci commit network
/etc/init.d/network restart

%>

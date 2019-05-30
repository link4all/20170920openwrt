#!/usr/bin/haserl
<%
# eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_mode" = "lan2wan" ];then
uci set network.@switch_vlan[0].ports="0 1 2 3 6t"
uci set network.@switch_vlan[1].ports="4 6t"
fi

if [ "$FORM_mode" = "wan2lan" ];then
uci set network.@switch_vlan[0].ports="0 2 3 4 6t"
uci set network.@switch_vlan[1].ports="1 6t"
fi

echo "{"
echo "\"status\":\" set ok!\""
echo "}"

uci commit network
/etc/init.d/network restart > /dev/null 2>&1

%>

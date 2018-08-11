#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_webctrl" -eq 1 ];then
uci set firewall.@zone[1].input="ACCEPT"
else
uci set firewall.@zone[1].input="REJECT"
fi
uci commit firewall

uci set uhttpd.main.listen_http="0.0.0.0:$FORM_webport"
uci commit uhttpd

echo "{"
echo "\"stat\":\"ok\""
echo "}"

/etc/init.d/firewall restart > /dev/null 2>&1
/etc/init.d/uhttpd restart  > /dev/null  2>&1



%>

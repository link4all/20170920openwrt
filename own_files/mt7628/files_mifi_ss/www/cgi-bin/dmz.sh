#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

uci set firewall.dmz=redirect
uci set firewall.dmz.src=wan
uci set firewall.dmz.dest_ip="$FORM_dmzip"
uci set firewall.dmz.target=DNAT
uci set firewall.dmz.proto=all

echo "{"
echo "\"ipaddr\":\"$FORM_dmzip\""
echo "}"

uci commit firewall
/etc/init.d/firewall restart

%>

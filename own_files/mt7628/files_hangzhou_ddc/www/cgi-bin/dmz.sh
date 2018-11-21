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
/etc/init.d/firewall restart 2>&1 > /dev/null

uci set n2n_v2.edge.ipaddr=$FORM_virtualip
uci commit n2n_v2
/etc/init.d/n2n_v2 restart  2>&1 > /dev/null

uci set network.n2n0.ipaddr=$FORM_virtualip
uci commit network
/etc/init.d/network 2>&1 > /dev/null
%>

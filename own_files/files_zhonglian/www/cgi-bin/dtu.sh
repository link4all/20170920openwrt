#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

uci set n2n_v2.@edge[0].ipaddr="$FORM_v_ip"
uci set n2n_v2.@edge[0].community="$FORM_community"
uci set n2n_v2.@edge[0].key="$FORM_passwd"
uci set firewall.n2n0.dest_ip="$FORM_plc_ip"

uci commit firewall
uci commit n2n_v2
/etc/init.d/n2n_v2 restart >/dev/null 2>&1 
/etc/init.d/firewall restart  >/dev/null 2>&1

echo "{"
echo "\"stat\":\"OK\""
echo "}"


%>


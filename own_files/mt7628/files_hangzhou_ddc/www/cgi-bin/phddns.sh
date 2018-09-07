#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""



uci set phddns.@phddns[0].username="$FORM_ddnsuser"
uci set phddns.@phddns[0].password="$FORM_ddnspass"
uci set phddns.@phddns[0].enabled=$FORM_enable


echo "{"
echo "\"status\":\"OK\""
echo "}"

uci commit phddns
/etc/init.d/phddns restart 2>&1 >/dev/null

%>
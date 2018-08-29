#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ $FORM_enable = 1 ];then

uci set phddns.@phddns[0].username="$FORM_ddnsuser"
uci set phddns.@phddns[0].password="$FORM_ddnspass"

fi

echo "{"
echo "\"status\":\"OK\""
echo "}"

uci commit phddns
/etc/init.d/phddns restart

%>

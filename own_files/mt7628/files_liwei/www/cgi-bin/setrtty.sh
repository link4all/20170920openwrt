#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_enable" -eq 1 ] ;then
uci set rtty.@rtty[0].enabled=1
else
uci set rtty.@rtty[0].enabled=0
fi

/etc/init.d/rtty restart  2>/dev/null  1>/dev/null
uci commit rtty

echo "{"
echo "\"success\":\"ok\""
echo "}"
%>


#!/usr/bin/haserl  --upload-limit=16348 --upload-dir=/tmp/
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_setclient" = "1" ];then
    uci set network.l2tp=interface
    uci set network.l2tp.server="$FORM_server_ip"
    uci set network.l2tp.username="$FORM_username"
    uci set network.l2tp.password="$FORM_password"
    uci set network.l2tp.proto='l2tp'
    uci commit network
    /etc/init.d/network restart 
fi

echo "{"
echo "\"stat\":\"ok\""
echo "}"



%>


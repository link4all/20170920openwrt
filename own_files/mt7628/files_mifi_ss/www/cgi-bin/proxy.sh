#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_mptcp" = "1" ] ;then
   uci set shadowsocks-libev.sss0.server="$FORM_server"
   uci set shadowsocks-libev.sss0.server_port="$FORM_port"
   uci set shadowsocks-libev.sss0.method="$FORM_method"
   uci set shadowsocks-libev.sss0.password="$FORM_passwd"
   uci set shadowsocks-libev.hi.obfs="$FORM_obfs"
   uci set shadowsocks-libev.hi.disabled=0
   else
   uci set shadowsocks-libev.hi.disabled=1

fi
 
uci commit shadowsocks-libev
/etc/init.d/shadowsocks-libev restart >/dev/null 2>&1

echo "{"
echo "\"stat\":\"OK\""
echo "}"
%>


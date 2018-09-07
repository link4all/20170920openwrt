#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_enable" -eq 1 ] ;then
uci del wireless.ra0.disabled >/dev/null 2>&1 
else
uci set wireless.ra0.disabled=1
fi
if [ "$FORM_hidssid" -eq 1 ] ;then
uci set wireless.ap.hidden=1
else
uci del wireless.ap.hidden >/dev/null 2>&1 
fi

uci set wireless.ap.ssid="$FORM_ssid"
uci set wireless.ap.encryption="$FORM_etype"
uci set wireless.ap.key="$FORM_epwd"
uci set wireless.ra0.channel="$FORM_channel"
uci set wireless.ra0.htmode="$FORM_bw"
uci set wireless.ra0.txpower="$FORM_txpower"
uci commit wireless
uci set network.wwan=interface
uci set network.wwan.proto="dhcp"

uci set wireless.ra0.hwmode="$FORM_mode"

if [ "$FORM_etype" = "wep" ];then
uci set wireless.ap.key=1
uci set wireless.ap.key1="$FORM_epwd"
fi
uci commit network

echo "{"
echo "\"success\":\"ok\""
echo "}"
/etc/init.d/network restart
%>


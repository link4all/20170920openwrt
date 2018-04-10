#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_enable" -eq 1 ] ;then
uci del wireless.mt7628.disable >/dev/null 2>&1 
else
uci set wireless.mt7628.disable=1
fi
if [ "$FORM_hidden" -eq 1 ] ;then
uci set wireless.ap.hidden=1
else
uci del wireless.ap.hidden >/dev/null 2>&1 
fi

uci set wireless.ap.ssid="$FORM_ssid"
uci set wireless.ap.encryption="$FORM_etype"
uci set wireless.ap.key="$FORM_epwd"
uci set wireless.mt7628.channel="$FORM_channel"
uci set wireless.mt7628.ht="$FORM_bw"
uci set wireless.mt7628.txpower="$FORM_txpower"
uci commit wireless
uci set network.wwan=interface
uci set network.wwan.proto="dhcp"
uci commit network

echo "{"
echo "\"success\":\"ok\""
echo "}"
/etc/init.d/network restart
%>

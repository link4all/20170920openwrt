#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_enable" -eq 1 ] ;then
uci del wireless.radio0.disabled >/dev/null 2>&1
else
uci set wireless.radio0.disabled=1
fi
if [ "$FORM_hidssid" -eq 1 ] ;then
uci set wireless.@wifi-iface[0].hidden=1
else
uci del wireless.@wifi-iface[0].hidden >/dev/null 2>&1
fi

uci set wireless.@wifi-iface[0].ssid="$FORM_ssid"
uci set wireless.@wifi-iface[0].encryption="$FORM_etype"
uci set wireless.@wifi-iface[0].key="$FORM_epwd"
uci set wireless.radio0.channel="$FORM_channel"
uci set wireless.radio0.htmode="$FORM_bw"
if [ "$FORM_bw" = "HT40"  ];then
uci set wireless.radio0.noscan="1"
else
  uci set wireless.radio0.noscan="0"
fi
uci set wireless.radio0.txpower="$FORM_txpower"
uci commit wireless

echo "{"
echo "\"success\":\"ok\""
echo "}"
/etc/init.d/network restart
%>

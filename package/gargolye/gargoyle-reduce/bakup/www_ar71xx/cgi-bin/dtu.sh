#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

uci set ser2net.@proxy[0].tcpport="$FORM_port"
uci set ser2net.@proxy[0].state="$FORM_state"
uci set ser2net.@proxy[0].timeout="$FORM_timeout"
uci set ser2net.@proxy[0].device="$FORM_device"
uci set ser2net.@proxy[0].baudrate="$FORM_mask"
uci set ser2net.@proxy[0].parity_ckeck="$FORM_parity"
uci set ser2net.@proxy[0].stopbit="$FORM_stopbit"
uci set ser2net.@proxy[0].databit="$FORM_databit"

echo "{"
echo "\"stat\":\"OK\""
echo "}"


uci commit ser2net
/etc/init.d/ser2net restart 2>&1 >/dev/null


%>

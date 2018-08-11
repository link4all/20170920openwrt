#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_dhcpenable" -eq 1 ];then
uci del dhcp.lan.ignore
  if [ -z "$FORM_leasetime" ]; then
  uci set dhcp.lan.leasetime="12h"
  else
  uci set dhcp.lan.leasetime="$FORM_leasetime"
  fi
  if [ -z "$FORM_limit" ]; then
  uci set dhcp.lan.limit=150
  else
  uci set dhcp.lan.limit="$FORM_limit" 
  fi
  if [ -z "$FORM_startip" ]; then
  uci set dhcp.lan.start=100
  else
  uci set dhcp.lan.start="$FORM_startip" 
  fi
echo "{"
echo "\"stat\":\"打开\""
echo "}"
else
uci set dhcp.lan.ignore=1
uci del dhcp.lan.leasetime
uci del dhcp.lan.limit
uci del dhcp.lan.start
echo "{"
echo "\"stat\":\"关闭\""
echo "}"
fi

uci commit dhcp
/etc/init.d/dnsmasq restart
/etc/init.d/odhcpd restart


%>

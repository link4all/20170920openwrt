#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

 if [ $FORM_dmzenable = '1' ];then
uci set firewall.dmz=redirect
uci set firewall.dmz.dest_ip=$FORM_dmzip
uci set firewall.dmz.src='wan'
uci set firewall.dmz.proto='all'
uci set firewall.dmz.target='DNAT'
 else
  uci del firewall.dmz
fi
 
uci commit firewall
/etc/init.d/firewall restart


echo "{"
echo "\"stat\":\"OK\""
echo "}"
/etc/init.d/network restart
%>


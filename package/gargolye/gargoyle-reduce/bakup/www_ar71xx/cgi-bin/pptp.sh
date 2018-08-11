#!/usr/bin/haserl  --upload-limit=16348 --upload-dir=/tmp/
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_setclient" = "1" ];then
    uci set network.pptp=interface
    uci set network.pptp.server="$FORM_server_ip"
    uci set network.pptp.username="$FORM_username"
    uci set network.pptp.password="$FORM_password"
    uci set network.pptp.proto='pptp'
    uci commit network
    /etc/init.d/network restart 
else
    uci del network.pptp
    uci commit network
    /etc/init.d/network restart
fi

if [ "$FORM_setserver" = "1" ];then
  if [ "$FORM_enable_server" = "1" ];then
    uci set pptpd.pptpd.enabled='1'
    uci set pptpd.pptpd.localip="$FORM_local_ipr"
    uci set pptpd.pptpd.remoteip="$FORM_remote_ip"
    uci set pptpd.@login[0].username="$FORM_username"
    uci set pptpd.@login[0].password="$FORM_password"
  else
    uci set pptpd.pptpd.enabled='0'
  fi
  uci commit pptpd
  /etc/init.d/pptpd restart 2>&1 >/dev/null
fi


echo "{"
echo "\"stat\":\"ok\""
echo "}"



%>

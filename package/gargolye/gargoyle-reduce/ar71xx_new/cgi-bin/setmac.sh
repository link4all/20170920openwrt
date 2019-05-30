#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""
if [ -n "$FORM_macserver" ];then
   uci set 4g.server.macserver="$FORM_macserver"
   uci commit 4g
fi
ip=`uci get 4g.server.macserver`
curl --connect-timeout 2 http://$ip/index.php -o /tmp/servermac >/dev/null 2>&1
if [ $? = 0 ];then
      mac=`cat /tmp/servermac`
      /lib/setmac.sh ${mac:0:2} ${mac:2:2} ${mac:4:2} ${mac:6:2} ${mac:8:2} ${mac:10:2} > /dev/null 2>&1
      . /lib/functions.sh
      . /lib/functions/system.sh
      newmac=`mtd_get_mac_binary art 4098 |tr "[a-z]" "[A-Z]"`
      firstboot -y > /dev/null 2>&1

          echo "{"
          echo "\"status\":\"ok\","
          echo "\"mac\":\"$newmac\""
          echo "}"
 else
          echo "{"
          echo "\"status\":\"Server not OK!\""
          echo "}" 
fi

%>

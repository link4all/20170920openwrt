#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_enable" = "1" ];then
uci set nodogsplash.@nodogsplash[0].enabled=1
else
uci set nodogsplash.@nodogsplash[0].enabled=0
fi
uci set nodogsplash.@nodogsplash[0].clientidletimeout=$FORM_timeout
uci set nodogsplash.@nodogsplash[0].clientforcetimeout=$FORM_timeout
if [ -n "$FORM_redirurl" ];then
uci set nodogsplash.@nodogsplash[0].redirecturl=$FORM_redirurl
else
  uci del nodogsplash.@nodogsplash[0].redirecturl
fi
# uci del nodogsplash.@nodogsplash[0].allow_site
# FORM_allow=`echo $FORM_allow |tr -d "\r"`
# if [ -n "$FORM_allow" ];then
#   uci del nodogsplash.@nodogsplash[0].preauthenticated_users
#   uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow tcp port 80 to 192.168.0.0/16'
#   for i in $FORM_allow
#    do
#      uci add_list nodogsplash.@nodogsplash[0].allow_site="$i"
#      uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80 to $i"
#    done
#  fi
 uci del dhcp.@dnsmasq[0].address
 FORM_forbid=`echo $FORM_forbid |tr -d "\r"`
 iptables -F BLKLIST
 if [ -n "$FORM_forbid" ];then
   for i in $FORM_forbid
    do
      uci add_list dhcp.@dnsmasq[0].address="/$i/0.0.0.0/"
	#iptables -I BLKLIST -d $i -j DROP	
    done
  fi


echo "{"
echo "\"stat\":\"ok\""
echo "}"


uci commit nodogsplash
uci commit dhcp
/etc/init.d/nodogsplash restart
/etc/init.d/dnsmasq reload


%>


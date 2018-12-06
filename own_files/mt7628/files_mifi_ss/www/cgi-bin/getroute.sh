#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

a=1
dump_route(){
  config_get target $1 target
  config_get netmask $1 netmask
  config_get gateway $1 gateway
  config_get metric $1 metric
  if [ $a -ne 1 ];then
 	echo ","
	fi
  echo "\"$a\":{"
  echo "\"target\":\"$target\","
  echo "\"netmask\":\"$netmask\","
  echo "\"gateway\":\"$gateway\","
  echo -n "\"metric\":\"$metric\""
  a=$(($a + 1))
  echo -n "}"
}

echo "{"
. /lib/functions.sh
config_load network
config_foreach dump_route route
echo "}"
%>

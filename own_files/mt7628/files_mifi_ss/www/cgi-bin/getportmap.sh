#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

a=1
dump_port(){
  config_get src_port $1 src_dport
  config_get dest_ip $1 dest_ip
  config_get dest_port $1 dest_port
  config_get proto $1 proto
  if [ $a -ne 1 ];then
 	echo ","
	fi
  echo "\"$a\":{"
  echo "\"src_port\":\"$src_port\","
  echo "\"dest_ip\":\"$dest_ip\","
  echo "\"dest_port\":\"$dest_port\","
  echo -n "\"proto\":\"$proto\""
  a=$(($a + 1))
  echo -n "}"
}

echo "{"
. /lib/functions.sh
config_load firewall
config_foreach dump_port redirect
echo "}"
%>

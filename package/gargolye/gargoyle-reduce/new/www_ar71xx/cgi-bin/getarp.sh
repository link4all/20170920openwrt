#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

echo "{"
i=0
cat /proc/net/arp |grep "br-lan"  | while read line
do
  mac=`echo $line |awk '{print $4}'`
  ip=`echo $line |awk '{print $1}'`
  flag=`echo $line |awk '{print $3}'`
  
  if [ $i -ne 0 ];then
 	echo ","
	fi
	
  let i+=1
  
  echo "\"$ip\":{"
  echo "\"mac\":\"$mac\","
  echo "\"flag\":\"$flag\""
  echo -n "}"
done
echo "}"
%>

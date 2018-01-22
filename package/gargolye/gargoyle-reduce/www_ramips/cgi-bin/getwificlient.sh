#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""
i=0
iwpriv ra0 show stainfo
cat /proc/kmsg   > /tmp/wifi-client-list&
killall cat 
cat  /tmp/wifi-client-list |grep -E '[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}[ ]' |cut -d] -f2 |awk  '{print $1, $7, $10,$18}' >/tmp/f_wifilist
echo "{"
cat /tmp/f_wifilist | while read line
do
  mac=`echo $line |awk '{print $1}'`
  signal=`echo $line |awk '{print $2}'|cut -d"/" -f1`
  bw=`echo $line |awk '{print $3}'`
  count=`echo $line |awk '{print $4}'|cut -d, -f1`
  if [ $i -ne 0 ];then
 	echo ","
	fi
	
  let i+=1
  
  echo "\"$mac\":{"
  echo "\"signal\":\"$signal\","
  echo "\"bw\":\"$bw\","
  echo "\"count\":\"$count\""
  echo -n "}"
done
echo "}"
%>

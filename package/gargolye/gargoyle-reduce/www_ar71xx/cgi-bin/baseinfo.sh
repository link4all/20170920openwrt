#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

uptime=`cut -d. -f1  /proc/uptime`
loadavg=`cat /proc/loadavg  | awk '{print $1",",$2",",$3}'`
time=`date "+%Y-%m-%d %H:%M:%S"`


echo "{"
echo "\"uptime\":\"$uptime\","
echo "\"loadavg\":\"$loadavg\","
echo "\"time\":\"$time\""
echo "}"



%>

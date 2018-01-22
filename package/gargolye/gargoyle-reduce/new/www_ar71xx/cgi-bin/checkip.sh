#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

apcli=`ifconfig | grep wlan0`
while [[ -z "$apcli" ]]
do
    apcli=`ifconfig | grep wlan0`
done

ip=`ifconfig wlan0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'`


echo "{\"result\":\"success\", \"ip\":\"$ip\"}"

%>

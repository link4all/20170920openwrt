#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ -n "$FORM_settime" ];then
date -s "$FORM_settime"
echo "{"
echo "\"time\":\"$FORM_settime\""
echo "}"
else
time=`date "+%Y-%m-%d %H:%M:%S"`
echo "{"
echo "\"time\":\"$time\""
echo "}"
fi


%>

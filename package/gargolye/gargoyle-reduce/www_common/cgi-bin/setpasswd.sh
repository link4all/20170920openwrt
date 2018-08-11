#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""


(echo "$FORM_passwd"; sleep 1;echo "$FORM_passwd") |passwd >/dev/null 2>&1


echo "{"
echo "\"stat\":\"$FORM_passwd\""
echo "}"



%>

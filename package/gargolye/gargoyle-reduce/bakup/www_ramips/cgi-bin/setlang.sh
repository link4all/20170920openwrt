#!/usr/bin/haserl
<%
#eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

uci set gargoyle.global.lang="$FORM_lang"
uci commit gargoyle

echo "{"
echo "\"lang\":\"FORM_lang\""
echo "}"
fi
%>

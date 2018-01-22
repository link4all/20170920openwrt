#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""


if [ -n "$FORM_timezone" ];then
zonename=`echo $FORM_timezone |awk '{print $1,$2}'`
timezone=`echo $FORM_timezone |awk '{print $3}'`
uci set system.@system[0].zonename="$zonename"
uci set system.@system[0].timezone="$timezone"
uci commit system
/etc/init.d/system restart >/dev/null 2>&1

echo "{"
echo "\"timezone\":\"$timezone\""
echo "}"
fi


%>

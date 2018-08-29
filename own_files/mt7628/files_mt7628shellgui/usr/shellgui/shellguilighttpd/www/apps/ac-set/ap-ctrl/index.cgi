#!/usr/bin/haserl
<%
action=$(echo "${FORM_body}" | jshon -e "action" -u)
[ -z "${action}" ] && exit
shellgui '{"action": "check_session", "session_type": "ap-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
if [ $? -ne 0 ] && [ "${action}" != "make_sysauth" ]; then
cat <<EOF
{"status":255}
EOF
exit
fi
. /usr/shellgui/shellguilighttpd/www/apps/ac-set/ap-ctrl/lib.sh && ${action}
%>

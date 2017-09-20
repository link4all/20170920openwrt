#!/usr/bin/haserl
<%
action=$(echo "${FORM_body}" | jshon -e "action" -u)
[ -z "${action}" ] && exit
shellgui '{"action": "check_session", "session_type": "ap-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && [ "${action}" != "make_sysauth" ] && exit 1
. /usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap-be-ctrld/lib.sh && ${action}
%>

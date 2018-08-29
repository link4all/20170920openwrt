#!/bin/sh
main() {
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $FORM_lang)
if shellgui '{"action": "make_sysauth", "username": "'"${FORM_username}"'", "password": "'"${FORM_password}"'"}' &>/dev/null; then
new_session="${FORM_username}-"$(cat /proc/sys/kernel/random/uuid | tr -d '-')
shellgui '{"action": "create_session", "session_type": "http-session", "session": "'"${new_session}"'"}' &>/dev/null
[ -z "$session_expires" ] && session_expires=1036800
	printf "Content-Type: text/html; charset=utf-8\r\nSet-Cookie: session=${new_session}; path=/; expires=$(date -d @$(expr $(date +%s) + $session_expires ) -u '+%A, %d-%b-%y %H:%M:%S') UTC\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Login_success}", "jump_url": "/?app=wifi", "seconds": 2000}
EOF
str_temp=$(echo '{
 "action": "notice_add_new",
 "Notice": {
  "Dest_type": "app",
  "Dest": "status",
  "Desc": "_LANG_Notice_User_login_from",
  "Detail": "_LANG_Notice_User_login_from_detail",
  "Variable": {}
 }
}' | jshon -e "Notice" -e "Variable" \
		-s "${FORM_username}" -i "username" \
		-s "${REMOTE_ADDR}" -i "ip" \
		-s "${HTTP_USER_AGENT}" -i "HTTP_USER_AGENT" \
		-p -p -j)
shellgui "$str_temp" &>/dev/null
	return
else
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Login_fail}"}
EOF
	return
fi
}

#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if
[ "${FORM_action}" = "set_pppoe" ] &>/dev/null
then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${FORM_dev} set_pppoe成功!"}
EOF
	return
elif [ "${FORM_action}" = "wan_pppoe" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Wan口已成功设置为pppoe!"}
EOF
	return
elif [ "${FORM_action}" = "wan_dhcp" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Wan口已成功设置为dhcp!"}
EOF
	return
elif [ "${FORM_action}" = "wan_static" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Wan口已成功设置为static!"}
EOF
	return
elif [ "${FORM_action}" = "wan_check_net" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"code":0,"list":[{"wan":"wan","status":0},{"wan":"wan2","status":1},{"wan":"wan3","status":0}]}
EOF
	return
fi
}

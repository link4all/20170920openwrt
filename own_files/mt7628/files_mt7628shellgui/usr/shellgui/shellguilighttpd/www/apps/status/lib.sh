#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "bw_set" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "{"$(env | grep FORM_dev_ | sed -e 's#^FORM_dev_#"#g' -e 's#=#":"#g' -e 's#$#M",#g' | tr -d '\n' | sed 's/,$//')"}" | jshon >/usr/shellgui/bw_set.conf
	cat <<EOF
{"status": 0, "msg": "编辑成功!"}
EOF
	return
fi
}
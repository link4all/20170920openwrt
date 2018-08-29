#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
if [ "${FORM_action}" = "get_scan" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
iw $FORM_dev scan 2>&1 | awk -F'\
' '{print "\""$0"\"" }'
echo "Success"
	exit
fi
}
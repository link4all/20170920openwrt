#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "get_nf_conntrack" ]; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat /proc/net/nf_conntrack
echo "Success"
fi
}

#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "set_port_remote" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	pre_w=$(echo "$FORM_data" | jshon -j)
	if [ -n "$pre_w" ]; then
		/usr/shellgui/shellguilighttpd/www/apps/port-remote/port-remote.sbin stop &>/dev/null
		echo "$pre_w" > /usr/shellgui/shellguilighttpd/www/apps/port-remote/port-remote.json
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modified_Successfully}!"}
EOF
		/usr/shellgui/shellguilighttpd/www/apps/port-remote/port-remote.sbin start &>/dev/null &
	else
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Modified_Failure}!"}
EOF
	fi
elif [ "${FORM_action}" = "del_cert" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if jshon -Q -F /usr/shellgui/shellguilighttpd/www/apps/port-remote/port-remote.json -e "Server" -a -e "pem" -u -p -p -p -e "Client" -a -e "pem" -u | grep -q "^$FORM_cert_file$"; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_The_Certificate_is_being_used}!"}
EOF
exit
fi
	rm -f /usr/shellgui/shellguilighttpd/www/apps/port-remote/certs/$FORM_cert_file
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_The_Certificate_Deleted}!"}
EOF
elif [ "${FORM_action}" = "mk_cert" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	export SSL_Size=${FORM_SSL_Size}
	export SSL_Expired_Time=${FORM_SSL_Expired_Time}
	export SSL_C=${FORM_SSL_C}
	export SSL_ST=${FORM_SSL_ST}
	export SSL_L=${FORM_SSL_L}
	export SSL_O=${FORM_SSL_O}
	export SSL_OU=${FORM_SSL_OU}
	export SSL_CN=${FORM_SSL_CN}
	touch /usr/shellgui/shellguilighttpd/www/apps/port-remote/certs/$FORM_name.pem
	/usr/shellgui/shellguilighttpd/www/apps/port-remote/port-remote.sbin ssl_gen $FORM_name
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_The_Certificate_Created}!"}
EOF
elif [ "${FORM_action}" = "get_certs" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cd /usr/shellgui/shellguilighttpd/www/apps/port-remote/certs/
	for pem in $(ls *.pem); do
		str="$str -s ${pem} -i 0"
	done
	echo '[]' | jshon $str -j
elif [ "${FORM_action}" = "get_setting" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat /usr/shellgui/shellguilighttpd/www/apps/port-remote/port-remote.json
fi
}

#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "do_speedtest" ] &>/dev/null; then
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
	pid=$(head -n 1 /tmp/speedtest.${FORM_dev} | jshon -e "pid")
	[ ${pid} -gt 0 ] && if kill -0 ${pid} &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		cat <<EOF
{"status":3,"msg":"${_LANG_Form_Doing_Speed_Test}!"}
EOF
	return 1
	fi
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ "${FORM_dev}" != "default" ]; then
		if [ -z "${FORM_dev}" ] && [ ! ifconfig | grep -qE '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' ]; then
			cat <<EOF
{"status":2,"msg":"${_LANG_Form_Device_does_not_exist_or_can_not_be_used}!"}
EOF
		return
		fi
	fi
	printf '' > /tmp/speedtest.${FORM_dev}
	if [ "${FORM_dev}" != "default" ]; then
	shellgui '{"action":"exec_command","cmd":"speed-test","arg":"--dev '"${FORM_dev}"' --log-suffix '"${FORM_dev}"'","is_daemon":1,"timeout":50000}' &>/dev/null
	else
	shellgui '{"action":"exec_command","cmd":"speed-test","arg":"--log-suffix '"${FORM_dev}"'", "is_daemon":1,"timeout":50000}' &>/dev/null
	fi
	sleep 1
	head -n 1 /tmp/speedtest.${FORM_dev} | grep pid || cat <<EOF
{"status":4,"msg":"${_LANG_Form_Speed_Test_Failure}!"}
EOF
	return
elif [ "${FORM_action}" = "get_line" ] &>/dev/null; then
# curl -d 'app=speed-test&action=get_line&dev=eth1&line=2' http://10.10.12.100/
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	awk 'BEGIN {err=1} NR == '${FORM_line}' {if (length($0) > 0) {print; err = 0}} END {exit err}' /tmp/speedtest.${FORM_dev} || cat <<EOF
{"status":1,"msg":"_LANG_Form_Get_line_fail!"}
EOF
	return
elif [ "${FORM_action}" = "ck_run" ] &>/dev/null; then
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
	pid=$(head -n 1 /tmp/speedtest.${FORM_dev} | jshon -e "pid")
	[ ${pid} -gt 0 ] && if kill -0 ${pid} &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		cat <<EOF
{"status":0,"msg":"${_LANG_Form_Doing_Speed_Test}!"}
EOF
	return
	else
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Out}!"}
EOF
	return
	fi
fi
}

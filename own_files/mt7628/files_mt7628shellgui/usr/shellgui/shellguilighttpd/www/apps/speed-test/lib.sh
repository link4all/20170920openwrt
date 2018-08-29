#!/bin/sh
main() {
# shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
# [ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "do_speedtest" ] &>/dev/null; then
# curl -d 'app=speed-test&action=do_speedtest&dev=eth1' http://10.10.12.100/
	pid=$(head -n 1 /tmp/speedtest.${FORM_dev} | jshon -e "pid")
	[ ${pid} -gt 0 ] && if kill -0 ${pid} &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		cat <<EOF
{"status": 3, "msg": "正在测速!"}
EOF
	return 1
	fi
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ "${FORM_dev}" != "default" ]; then
		if [ -z "${FORM_dev}" ] && [ ! ifconfig | grep -qE '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' ]; then
			cat <<EOF
{"status": 2, "msg": "设备不存在或不能使用!"}
EOF
		return
		fi
	fi
	printf '' > /tmp/speedtest.${FORM_dev}
	if [ "${FORM_dev}" != "default" ]; then
	shellgui '{"action": "exec_command", "cmd": "speed-test", "arg": "--dev '"${FORM_dev}"' --log-suffix '"${FORM_dev}"'", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	else
	shellgui '{"action": "exec_command", "cmd": "speed-test", "arg": "--log-suffix '"${FORM_dev}"'", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	fi
	sleep 1
	head -n 1 /tmp/speedtest.${FORM_dev} | grep pid || cat <<EOF
{"status": 4, "msg": "测速失败!"}
EOF
	return
elif [ "${FORM_action}" = "get_line" ] &>/dev/null; then
# curl -d 'app=speed-test&action=get_line&dev=eth1&line=2' http://10.10.12.100/
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	awk 'BEGIN {err=1} NR == '${FORM_line}' {if (length($0) > 0) {print; err = 0}} END {exit err}' /tmp/speedtest.${FORM_dev} || cat <<EOF
{"status": 1, "msg": "取行失败!"}
EOF
	return
elif [ "${FORM_action}" = "ck_run" ] &>/dev/null; then
# curl -d 'app=speed-test&action=ck_run&dev=eth1' http://10.10.12.100/
	pid=$(head -n 1 /tmp/speedtest.${FORM_dev} | jshon -e "pid")
	[ ${pid} -gt 0 ] && if kill -0 ${pid} &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		cat <<EOF
{"status": 0, "msg": "正在测速!"}
EOF
	return
	else
		cat <<EOF
{"status": 1, "msg": "已退出!"}
EOF
	return
	fi
fi
}

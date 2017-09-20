#!/bin/sh
check_session() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
}
main() {
	if [ "${FORM_action}" = "change_lang" ] &>/dev/null; then
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $FORM_lang)
		printf "Content-Type: text/html; charset=utf-8\r\nSet-Cookie: lang=${FORM_lang}; path=/\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "$FORM_lang ${_LANG_Form_lang_has_assigned}", "jump_url": "${HTTP_REFERER}", "seconds": 2000}
EOF
rm -f /tmp/$COOKIE_session.temp_*
return
	elif [ "${FORM_action}" = "change_theme" ] &>/dev/null; then
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
		printf "Content-Type: text/html; charset=utf-8\r\nSet-Cookie: theme=${FORM_theme}; path=/\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Theme_is_changed}", "jump_url": "${HTTP_REFERER}", "seconds": 2000}
EOF
	fi

	check_session
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_QuickT_' ${FORM_app} $COOKIE_lang)
	if [ "${FORM_action}" = "reboot" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_QuickT_Rebooting}", "jump_url": "${HTTP_REFERER}", "seconds": 90000}
EOF
		reboot &>/dev/null
	elif [ "${FORM_action}" = "restart_firewall" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_QuickT_Restarting_Firewall}", "jump_url": "${HTTP_REFERER}", "seconds": 10000}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	elif [ "${FORM_action}" = "list_firewall" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
<pre style="text-align: left">$(iptables-save)</pre>
EOF
	elif [ "${FORM_action}" = "nics_status" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
<pre style="text-align: left">$(shellgui '{"action": "get_ifces_status", "readable": 1}' | jshon)</pre>
EOF
	elif [ "${FORM_action}" = "restart_network" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_QuickT_Restarting_Network}", "jump_url": "${HTTP_REFERER}", "seconds": 10000}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	elif [ "${FORM_action}" = "mem_used" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
<pre style="text-align: left">$(shellgui '{"action": "get_mem_status", "readable": 1}' | jshon)</pre>
<button class="btn btn-default" onclick='quickSubmit("{\"response\":\"json\",\"confirm\":\"${_LANG_QuickT_Do_you_want_to_clean_Memory}?\", \"app\":\"home\",\"action\":\"clean_mem\"}")'>${_LANG_QuickT_Clean_Memory}</button>
EOF
	elif [ "${FORM_action}" = "clean_mem" ] &>/dev/null; then
	echo 3 > /proc/sys/vm/drop_caches
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Memory_has_Cleaned}"}
EOF
# cat <<EOF
# <pre style="text-align: left">$(shellgui '{"action": "get_mem_status", "readable": 1}' | jshon)</pre>
# EOF
	elif [ "${FORM_action}" = "system_log" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
<pre style="text-align: left">$(dmesg)</pre>
EOF
	elif [ "${FORM_action}" = "kernel_log" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
<pre style="text-align: left">$(logread)</pre>
EOF
	elif [ "${FORM_action}" = "netstat_tcp_udp" ] &>/dev/null; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
str=$(netstat -tulnp | grep -vE "Active Internet connections|Proto.*Recv-Q" | awk '{if ($6 == "LISTEN") print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td><td>"$7"</td></tr>" ; else print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>-</td><td>"$6"</td></tr>"}')
echo '<table class="table table-condensed"><thead><tr><td>Proto</td><td>Recv-Q</td><td>Send-Q</td><td>Local Address</td><td>Foreign Address</td><td>State</td><td>PID/Program name</td></tr></thead><tbody>'"$str"'</tbody></table>'
	fi
}
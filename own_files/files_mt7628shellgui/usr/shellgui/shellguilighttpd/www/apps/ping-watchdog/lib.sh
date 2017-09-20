#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "ping_watchdog_setting" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ "$FORM_status" != "true" ]; then
	rm -f /usr/shellgui/shellguilighttpd/www/apps/ping-watchdog/root.cron
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Startup_Disabled}"}
EOF
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/cron", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
	fi
result=$(echo '{}' | jshon -Q \
-d "exec_interval" -n $FORM_exec_interval -i "exec_interval" \
-d "delay_time" -n $FORM_delay_time -i "delay_time" \
-d "ping_count" -n $FORM_ping_count -i "ping_count" \
-d "host" -s "$FORM_host" -i "host" -j)
if [ "$FORM_timeout_action" = "wan" ] || [ "$FORM_timeout_action" = "reboot" ]; then
result=$(echo "$result" | jshon -d "timeout_action" -s "$FORM_timeout_action" -i "timeout_action" -j)
else
result=$(echo "$result" | jshon -d "timeout_action" -s "$FORM_script" -i "timeout_action" -j)
fi
if [ $(echo "$result" | jshon -a -u | sed -e '/^$/d' | wc -l) -ne 5 ]; then
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Filled_with_errors}"}
EOF
	return
fi
echo "$result" > /usr/shellgui/shellguilighttpd/www/apps/ping-watchdog/ping-watchdog.json
cat <<EOF > /usr/shellgui/shellguilighttpd/www/apps/ping-watchdog/root.cron
*/${FORM_exec_interval} * * * * cat /usr/shellgui/shellguilighttpd/www/apps/ping-watchdog/ping-watchdog.json | /usr/shellgui/progs/main.sbin ping_watchdog
EOF
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Startup_Enabled}"}
EOF
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/cron", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
fi
}
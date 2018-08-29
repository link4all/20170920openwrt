#!/bin/sh
base_dir="/usr/shellgui/shellguilighttpd/www/apps/shadowsocks"
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "get_client_configs" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result=$(jshon -j -F $base_dir/shadowsocks.json)
	pidof ss-server &>/dev/null && server_status=1 || server_status=0
	pidof ss-local &>/dev/null && local_status=1 || local_status=0
	pidof ss-redir &>/dev/null && redir_status=1 || redir_status=0
	echo "$result" | jshon -n {} -i "status" -e "status" -n ${server_status} -i "server" -n ${local_status} -i "local" -n ${redir_status} -i "redir" -p -j
	return
elif [ "${FORM_action}" = "set_shadowsocks" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	. /usr/shellgui/shellguilighttpd/www/apps/firewall-extra/lib.sh
	check_geoip
	if [ $? -ne 0 ]; then
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_GEOIP_havent_updated__plz_Apply_after_it_updated}!"}
EOF
return
	fi
_Global_SW_mode=$(uci get network.wan._Global_SW_mode 2>/dev/null)
[ -n "$_Global_SW_mode" ] && if ! echo "$_Global_SW_mode" | grep -q "shadowsocks"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	if [ $(echo "$FORM_data" | jshon -e "redir" -e "enabled" -u) -gt 0 ]; then
		uci set network.wan._Global_SW_mode=shadowsocks
		uci commit network
	else
	
	uci set network.wan._Global_SW_mode=;uci commit network
	fi
	[ "$(echo "$FORM_data" | jshon -t)" = "object" ] && echo "$FORM_data" | jshon > $base_dir/shadowsocks.json
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
	rm -f $base_dir/root.cron
	# $base_dir/shadowsocks.sbin set_shadowsocks_cron_watchdog
	$base_dir/S1401-shadowsocks.init restart &>/dev/null
	if lsmod | grep -q xt_geoip; then
	$base_dir/F995-shadowsocks.fw restart &>/dev/null
	else
	(/etc/init.d/firewall stop;rmmod xt_geoip;insmod xt_geoip) &>/dev/null
	shellgui  '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	fi
	return
fi
}
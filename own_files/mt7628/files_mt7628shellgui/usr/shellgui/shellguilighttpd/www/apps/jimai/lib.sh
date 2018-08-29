#!/bin/sh
get_lan_mac() {
	shellgui '{"action": "get_ifces_status"}' | jshon -e "br-lan" -e "mac" -u
}
gen_wifidog_config() {
	lan_ip=$(shellgui '{"action": "get_ifces_status"}' | jshon -e "br-lan" -e "ip" -u)
	GatewayID=$(get_lan_mac | tr -d ':' | tr 'a-z' 'A-Z')
	if [ -n "$lan_ip" ]; then
		sed -e 's#{-lan_ip-}#'"${lan_ip}"'#g' -e 's#{-GatewayID-}#'"${GatewayID}"'#g' /usr/shellgui/shellguilighttpd/www/apps/jimai/wifidog.conf >/etc/wifidog.conf
		sed -e 's#{-lan_ip-}#'"${lan_ip}"'#g' /usr/shellgui/shellguilighttpd/www/apps/jimai/local_server.conf >/etc/local_server.conf
	fi
}
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
fi
}

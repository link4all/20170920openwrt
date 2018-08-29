#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "disable_dns_cdn" ] &>/dev/null; then
rm -f /usr/shellgui/shellguilighttpd/www/apps/dns-cdn/all.dnsmasqd
uci set chinadns.@chinadns[0].enable=0
uci commit chinadns
shellgui '{"action": "exec_command", "cmd": "/usr/shellgui/shellguilighttpd/www/apps/dns-cdn/S1000-dnscdn.init", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Disnable} ${_LANG_Form_DNS_CDN_Accelerator}!"}
EOF
	return
elif [ "${FORM_action}" = "enable_dns_cdn" ] &>/dev/null; then
echo 'server=/#/127.0.0.1#45353' >/usr/shellgui/shellguilighttpd/www/apps/dns-cdn/all.dnsmasqd
uci set chinadns.@chinadns[0].enable=1
uci commit chinadns
shellgui '{"action": "exec_command", "cmd": "/usr/shellgui/shellguilighttpd/www/apps/dns-cdn/S1000-dnscdn.init", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Enable} ${_LANG_Form_DNS_CDN_Accelerator}!"}
EOF
	return
elif [ "${FORM_action}" = "set_dnscdn" ] &>/dev/null; then
socks5tproxy_file=/usr/shellgui/shellguilighttpd/www/apps/dns-cdn/dnsforward.socks5tproxy
[ $FORM_enable_socks5tproxy -gt 0 ] && touch ${socks5tproxy_file} || rm -f ${socks5tproxy_file}
uci batch <<EOF
set chinadns.@chinadns[0].server="${FORM_chinadns_ips},127.0.0.1#45354"
set dns-forwarder.@dns-forwarder[0].enable=${FORM_enable_dnsforwader}
set dns-forwarder.@dns-forwarder[0].dns_servers="${FORM_dns_forwader_ip}"
EOF
uci commit chinadns
uci commit dns-forwarder
shellgui '{"action": "exec_command", "cmd": "/usr/shellgui/shellguilighttpd/www/apps/dns-cdn/S1000-dnscdn.init", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_success}!"}
EOF
	return
fi
}

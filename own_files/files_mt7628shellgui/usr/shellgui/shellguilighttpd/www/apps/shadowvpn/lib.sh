#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "set_shadowvpn_server" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
uci batch <<EOF
set shadowvpn.@shadowvpn[0].enable='1'
set shadowvpn.@shadowvpn[0].server="${FORM_server}"
set shadowvpn.@shadowvpn[0].mode='server'
set shadowvpn.@shadowvpn[0].port="${FORM_port}"
set shadowvpn.@shadowvpn[0].password="${FORM_password}"
set shadowvpn.@shadowvpn[0].concurrency="${FORM_concurrency}"
set shadowvpn.@shadowvpn[0].net="${FORM_net}"
set shadowvpn.@shadowvpn[0].mtu="${FORM_mtu}"
set shadowvpn.@shadowvpn[0].intf='ss0'
commit shadowvpn
set network.svpn=
commit network
set firewall.svpn_zone=
set firewall.svpn_lan_forwarding=
set firewall.ra_shadowvpn=
set firewall.svpn_wan_forwarding=
commit firewall
set network.svpn='interface'
set network.svpn.ifname='ss0'
set network.svpn.proto='none'
set network.svpn.defaultroute='0'
set network.svpn.peerdns='0'
set firewall.svpn_zone='zone'
set firewall.svpn_zone.name='svpn'
set firewall.svpn_zone.network='svpn'
set firewall.svpn_zone.input='ACCEPT'
set firewall.svpn_zone.output='ACCEPT'
set firewall.svpn_zone.forward='ACCEPT'
set firewall.svpn_zone.mtu_fix='1'
set firewall.svpn_zone.masq='1'
set firewall.svpn_lan_forwarding='forwarding'
set firewall.svpn_lan_forwarding.src='lan'
set firewall.svpn_lan_forwarding.dest='svpn'
set firewall.lan_svpn_forwarding='forwarding'
set firewall.lan_svpn_forwarding.src='svpn'
set firewall.lan_svpn_forwarding.dest='lan'
set firewall.ra_shadowvpn='remote_accept'
set firewall.ra_shadowvpn.zone='wan'
set firewall.ra_shadowvpn.local_port="${FORM_port}"
set firewall.ra_shadowvpn.remote_port="${FORM_port}"
set firewall.ra_shadowvpn.proto="${FORM_proto}"
set firewall.svpn_wan_forwarding='forwarding'
set firewall.svpn_wan_forwarding.src='svpn'
set firewall.svpn_wan_forwarding.dest='wan'
commit network
commit firewall
EOF
(/usr/shellgui/shellguilighttpd/www/apps/shadowvpn/shadowvpn.sbin set_shadowvpn_cron_watchdog) &>/dev/null
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart ; /etc/init.d/shadowvpn restart ; /usr/shellgui/shellguilighttpd/www/apps/shadowvpn/F996-shadowvpn.fw restart", "is_daemon": 1, "timeout": 50000}' &> /dev/null
	return
elif [ "${FORM_action}" = "set_shadowvpn_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
_Global_SW_mode=$(uci get network.wan._Global_SW_mode 2>/dev/null)
[ -n "$_Global_SW_mode" ] && if ! echo "$_Global_SW_mode" | grep -q "shadowvpn"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	. /usr/shellgui/shellguilighttpd/www/apps/firewall-extra/lib.sh
	check_geoip
	if [ $? -ne 0 ]; then
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_GEOIP_havent_updated__plz_Apply_after_it_updated}!"}
EOF
return
	fi
	if echo "${FORM_server}" | grep -q '0.0.0.0'; then
		cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Server_filed_Error}!"}
EOF
		return
	elif [ -z "${FORM_server_iner_ip}" ]; then
		cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Internal_IP_Mask_filed_Error}!"}
EOF
		return
	elif [ "$(echo ${FORM_net} | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')" = "${FORM_server_iner_ip}" ]; then
		cat <<EOF
{"status": 1, "msg": "net != server_iner_ip!"}
EOF
		return
	fi
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
uci set network.wan._Global_SW_mode=shadowvpn
uci commit network
uci batch <<EOF
set shadowvpn.@shadowvpn[0].enable='1'
set shadowvpn.@shadowvpn[0].server="${FORM_server}"
set shadowvpn.@shadowvpn[0].mode='client'
set shadowvpn.@shadowvpn[0].port="${FORM_port}"
set shadowvpn.@shadowvpn[0].password="${FORM_password}"
set shadowvpn.@shadowvpn[0].concurrency="${FORM_concurrency}"
set shadowvpn.@shadowvpn[0].net="${FORM_net}"
set shadowvpn.@shadowvpn[0].mtu="${FORM_mtu}"
set shadowvpn.@shadowvpn[0].intf='ss0'
set shadowvpn.@shadowvpn[0].except_cc="${FORM_except_cc}"
set shadowvpn.@shadowvpn[0].server_iner_ip="${FORM_server_iner_ip}"
set shadowvpn.@shadowvpn[0].server_iner_lanip="${FORM_server_iner_lanip}"
set shadowvpn.@shadowvpn[0].server_iner_lanmask="${FORM_server_iner_lanmask}"
commit shadowvpn
set network.svpn=
commit network
set firewall.svpn_zone=
set firewall.svpn_lan_forwarding=
set firewall.ra_shadowvpn=
set firewall.svpn_wan_forwarding=
commit firewall
set network.svpn='interface'
set network.svpn.ifname='ss0'
set network.svpn.proto='none'
set network.svpn.defaultroute='0'
set network.svpn.peerdns='0'
set firewall.svpn_zone='zone'
set firewall.svpn_zone.name='svpn'
set firewall.svpn_zone.network='svpn'
set firewall.svpn_zone.input='ACCEPT'
set firewall.svpn_zone.output='ACCEPT'
set firewall.svpn_zone.forward='ACCEPT'
set firewall.svpn_zone.mtu_fix='1'
set firewall.svpn_zone.masq='1'
set firewall.svpn_lan_forwarding='forwarding'
set firewall.svpn_lan_forwarding.src='lan'
set firewall.svpn_lan_forwarding.dest='svpn'
set firewall.lan_svpn_forwarding='forwarding'
set firewall.lan_svpn_forwarding.src='svpn'
set firewall.lan_svpn_forwarding.dest='lan'
set firewall.ra_shadowvpn='remote_accept'
set firewall.ra_shadowvpn.zone='wan'
set firewall.ra_shadowvpn.local_port="${FORM_port}"
set firewall.ra_shadowvpn.remote_port="${FORM_port}"
set firewall.ra_shadowvpn.proto="udp"
set firewall.svpn_wan_forwarding='forwarding'
set firewall.svpn_wan_forwarding.src='svpn'
set firewall.svpn_wan_forwarding.dest='wan'
commit network
commit firewall
EOF
(/usr/shellgui/shellguilighttpd/www/apps/shadowvpn/shadowvpn.sbin set_shadowvpn_cron_watchdog) &>/dev/null
lsmod | grep -q xt_geoip || (/etc/init.d/firewall stop;rmmod xt_geoip;insmod xt_geoip) &>/dev/null
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart ; /etc/init.d/shadowvpn restart ; /usr/shellgui/shellguilighttpd/www/apps/shadowvpn/F996-shadowvpn.fw restart", "is_daemon": 1, "timeout": 50000}' &> /dev/null
	return
elif [ "${FORM_action}" = "disable_shadowvpn" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
_Global_SW_mode=$(uci get network.wan._Global_SW_mode 2>/dev/null)
[ -n "$_Global_SW_mode" ] && if ! echo "$_Global_SW_mode" | grep -q "shadowvpn"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
uci batch <<EOF
set shadowvpn.@shadowvpn[0].enable='0'
commit shadowvpn
set network.svpn=
commit network
set firewall.svpn_zone=
set firewall.svpn_lan_forwarding=
set firewall.ra_shadowvpn=
set firewall.svpn_wan_forwarding=
commit firewall
EOF
uci set network.wan._Global_SW_mode=;uci commit network
rm -f /usr/shellgui/shellguilighttpd/www/apps/shadowvpn/root.cron
/etc/init.d/cron restart &>/dev/null
/tmp/shadowvpn.firewall.running
/etc/init.d/shadowvpn stop &>/dev/null
	return
fi
}

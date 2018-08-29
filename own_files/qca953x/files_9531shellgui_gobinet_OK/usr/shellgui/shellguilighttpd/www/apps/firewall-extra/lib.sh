#!/bin/sh
check_geoip() {
	ver=$(jshon -Q -e "ver" -u -F /usr/share/xt_geoip/last_version)
	[ ${ver:--1} -ge 0 ] && return 0 || return 1
}
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "enable_geoip_update" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Enable} ${_LANG_Form_GEOIP_Auto_Update}!"}
EOF
echo '0 3 * * * /usr/shellgui/progs/main.sbin geoip_update' >/usr/shellgui/shellguilighttpd/www/apps/firewall-extra/root.cron
shellgui '{"action":"exec_command","cmd":"/usr/shellgui/progs/main.sbin","arg":"geoip_update","is_daemon":1, "timeout":50000}' &>/dev/null
	return
elif [ "${FORM_action}" = "disable_geoip_update" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Disable} ${_LANG_Form_GEOIP_Auto_Update}!"}
EOF
rm -f /usr/shellgui/shellguilighttpd/www/apps/firewall-extra/root.cron
	return
elif [ "${FORM_action}" = "reload_geoip" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Reloaded}!","jump_url":"/?app=firewall-extra","seconds":5000}
EOF
/etc/init.d/firewall stop &>/dev/null
rmmod xt_geoip
insmod xt_geoip
shellgui  '{"action":"exec_command","cmd":"/etc/init.d/firewall","arg":"restart","is_daemon":1,"timeout":50000}' &>/dev/null
elif [ "${FORM_action}" = "enabled_syn_flood" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ ${FORM_var} -gt 0 ]; then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Enable} ${_LANG_Form_SYN_flood_Protection} ${_LANG_Form_Modify_success__Restarting_Firewall}!","seconds":5000}
EOF
	else
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Disable} ${_LANG_Form_SYN_flood_Protection} ${_LANG_Form_Modify_success__Restarting_Firewall}!","seconds":5000}
EOF
	fi
uci set firewall.$FORM_syn_flood_cfg.syn_flood=${FORM_var:-0}
uci commit firewall
shellgui '{"action":"exec_command","cmd":"/etc/init.d/firewall","arg":"restart","is_daemon":1,"timeout":50000}' &>/dev/null
	return
elif [ "${FORM_action}" = "set_firewall" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_success__Restarting_Firewall}!","seconds":5000}
EOF
uci batch <<EOF &>/dev/null
set firewall.$FORM_wan_zone_cfg.input='${FORM_wan_zone_input:-REJECT}'
set firewall.$FORM_Allow_DHCP_Renew_cfg.target='${FORM_Allow_DHCP_Renew_target:-REJECT}'
set firewall.$FORM_Allow_Ping_cfg.target='${FORM_Allow_Ping_target:-REJECT}'
set firewall.$FORM_Allow_IGMP_cfg.target='${FORM_Allow_IGMP_target:-REJECT}'
set firewall.$FORM_Allow_DHCPv6_cfg.target='${FORM_Allow_DHCPv6_target:-REJECT}'
set firewall.$FORM_Allow_MLD_cfg.target='${FORM_Allow_MLD_target:-REJECT}'
set firewall.$FORM_Allow_ICMPv6_Input_cfg.target='${FORM_Allow_ICMPv6_Input_target:-REJECT}'
set firewall.$FORM_Allow_ICMPv6_Forward_cfg.target='${FORM_Allow_ICMPv6_Forward_target:-REJECT}'
EOF
firewall_str=$(uci show -X firewall)
echo "${FORM_wan_zone_input}" | grep -q ACCEPT && port_enabled=0 || port_enabled=1
echo "$firewall_str" | grep -E 'Allow-[T|C|P|U|D|P]*-Port-Wan' | cut -d '.' -f2 | while read allow_ports_cfg; do
uci set firewall.${allow_ports_cfg}=
done
for port in $(echo $FORM_allow_tcp_ports | tr ',' '\n'); do
uci batch <<EOF &>/dev/null
add firewall rule
set firewall.@rule[-1].src='wan'
set firewall.@rule[-1].dest_port='${port}'
set firewall.@rule[-1].target='ACCEPT'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].name='Allow-TCP-Port-Wan'
set firewall.@rule[-1].enabled='${port_enabled}'
EOF
done
for port in $(echo $FORM_allow_udp_ports | tr ',' '\n'); do
uci batch <<EOF &>/dev/null
add firewall rule
set firewall.@rule[-1].src='wan'
set firewall.@rule[-1].dest_port='${port}'
set firewall.@rule[-1].target='ACCEPT'
set firewall.@rule[-1].proto='udp'
set firewall.@rule[-1].name='Allow-UDP-Port-Wan'
set firewall.@rule[-1].enabled='${port_enabled}'
EOF
done
for port in $(echo $FORM_allow_tcpudp_ports | tr ',' '\n'); do
uci batch <<EOF &>/dev/null
add firewall rule
set firewall.@rule[-1].src='wan'
set firewall.@rule[-1].dest_port='${port}'
set firewall.@rule[-1].target='ACCEPT'
set firewall.@rule[-1].proto='tcpudp'
set firewall.@rule[-1].name='Allow-TCPUDP-Port-Wan'
set firewall.@rule[-1].enabled='${port_enabled}'
EOF
done
uci commit firewall
shellgui '{"action":"exec_command","cmd":"/etc/init.d/firewall","arg":"restart","is_daemon":1,"timeout":50000}' &>/dev/null
	return
fi
}

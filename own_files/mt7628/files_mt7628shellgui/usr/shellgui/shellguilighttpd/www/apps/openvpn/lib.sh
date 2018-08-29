#!/bin/sh
openvpn_dir="/usr/shellgui/shellguilighttpd/www/apps/openvpn"
correct_client_conf() {
[ -n "$1" ] || return
sed -i "s#^status[ ].*#status          /tmp/openvpn/current_status#" /etc/openvpn/client.conf
sed -i "s#^ca[ ].*#ca              $1/client_ca.crt#" /etc/openvpn/client.conf
sed -i "s#^cert[ ].*#cert            $1/client.crt#" /etc/openvpn/client.conf
sed -i "s#^key[ ].*#key             $1/client.key#" /etc/openvpn/client.conf
sed -i "s#^tls-auth[ ].*#tls-auth        $1/client_ta.key 1#" /etc/openvpn/client.conf
}
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "set_openvpn_server" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
for opt in internal_ip internal_mask port;do
	if [ -z "$(eval echo '$'FORM_${opt})" ]; then 
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Options_can_not_be_empty}!"}
EOF
	return
	fi
done
openvpn_dir_sz=$(du -s /etc/openvpn | awk '{print $1}')
if [ ${openvpn_dir_sz:-0} -gt 20  ]; then
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
else
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!${_LANG_Form_Generating_certificate_files__please_wait_5_minutes}", "jump_url": "/?app=openvpn", "seconds": 300000}
EOF
fi
mv -f /etc/openvpn/client.conf /etc/openvpn/client.conf.bak
[ -f /etc/openvpn/server.conf.bak ] && mv -f /etc/openvpn/server.conf.bak /etc/openvpn/server.conf
uci batch <<EOF
set openvpn.custom_config='openvpn'
set openvpn.custom_config.enabled='1'
set openvpn.custom_config.config='/etc/openvpn/server.conf'
set openvpn.custom_config.up='${openvpn_dir}/openvpn.up'
set openvpn.custom_config.down='${openvpn_dir}/openvpn.down'
EOF
uci commit openvpn
uci batch <<EOF
-c${openvpn_dir} set openvpn_uci.keysize=
-c${openvpn_dir} set openvpn_uci.server.enabled='true'
-c${openvpn_dir} set openvpn_uci.client.enabled='false'
-c${openvpn_dir} set openvpn_uci.server=server
-c${openvpn_dir} set openvpn_uci.server.internal_ip="${FORM_internal_ip}"
-c${openvpn_dir} set openvpn_uci.server.internal_mask="${FORM_internal_mask}"
-c${openvpn_dir} set openvpn_uci.server.port="${FORM_port}"
-c${openvpn_dir} set openvpn_uci.server.duplicate_cn="${FORM_duplicate_cn}"
-c${openvpn_dir} set openvpn_uci.server.redirect_gateway="${FORM_redirect_gateway}"
EOF
if echo "${FORM_cipher}" | grep -q "BF-CBC"; then
	uci -c${openvpn_dir} set openvpn_uci.server.cipher="BF-CBC"
	uci -c${openvpn_dir} set openvpn_uci.server.keysize="$(echo ${FORM_cipher} |grep -Eo '[0-9]*')"
else
	uci -c${openvpn_dir} set openvpn_uci.server.cipher="${FORM_cipher}"
fi
eval $(ipcalc.sh $(uci get network.lan.ipaddr) $(uci get network.lan.netmask))
uci batch <<EOF
-c${openvpn_dir} set openvpn_uci.server.client_to_client="${FORM_client_to_client}"
-c${openvpn_dir} set openvpn_uci.server.subnet_access="${FORM_subnet_access}"
-c${openvpn_dir} set openvpn_uci.server.proto="${FORM_proto}"
-c${openvpn_dir} set openvpn_uci.server.subnet_ip="${NETWORK}"
-c${openvpn_dir} set openvpn_uci.server.subnet_mask="${NETMASK}"
set network.vpn=
commit network
set firewall.vpn_zone=
set firewall.vpn_lan_forwarding=
set firewall.ra_openvpn=
set firewall.vpn_wan_forwarding=
commit firewall
set network.vpn='interface'
set network.vpn.ifname='tun0'
set network.vpn.proto='none'
set network.vpn.defaultroute='0'
set network.vpn.peerdns='0'
set firewall.vpn_zone='zone'
set firewall.vpn_zone.name='vpn'
set firewall.vpn_zone.network='vpn'
set firewall.vpn_zone.input='ACCEPT'
set firewall.vpn_zone.output='ACCEPT'
set firewall.vpn_zone.forward='ACCEPT'
set firewall.vpn_zone.mtu_fix='1'
set firewall.vpn_zone.masq='1'
set firewall.vpn_lan_forwarding='forwarding'
set firewall.vpn_lan_forwarding.src='lan'
set firewall.vpn_lan_forwarding.dest='vpn'
set firewall.lan_vpn_forwarding='forwarding'
set firewall.lan_vpn_forwarding.src='vpn'
set firewall.lan_vpn_forwarding.dest='lan'
set firewall.ra_openvpn='remote_accept'
set firewall.ra_openvpn.zone='wan'
set firewall.ra_openvpn.local_port="${FORM_port}"
set firewall.ra_openvpn.remote_port="${FORM_port}"
set firewall.ra_openvpn.proto="${FORM_proto}"
set firewall.vpn_wan_forwarding='forwarding'
set firewall.vpn_wan_forwarding.src='vpn'
set firewall.vpn_wan_forwarding.dest='wan'
EOF
uci commit network
uci commit firewall
uci -c${openvpn_dir} commit openvpn_uci
shellgui '{"action": "exec_command", "cmd": "'"${openvpn_dir}"'/openvpn.sbin", "arg": "regenerate_server_and_allowed_clients_from_uci ; /etc/init.d/openvpn stop ; /etc/init.d/network restart", "is_daemon": 1, "timeout": 50000}' &> /dev/null
	return
elif [ "${FORM_action}" = "set_openvpn_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
_Global_SW_mode=$(uci get network.wan._Global_SW_mode 2>/dev/null)
[ -n "$_Global_SW_mode" ] && if ! echo "$_Global_SW_mode" | grep -q "openvpn"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	uci set network.wan._Global_SW_mode=openvpn
	uci commit network
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
uci batch <<EOF
set network.vpn=
commit network
set firewall.vpn_zone=
set firewall.vpn_lan_forwarding=
set firewall.ra_openvpn=
set firewall.vpn_wan_forwarding=
commit firewall
EOF
mv -f /etc/openvpn/server.conf /etc/openvpn/server.conf.bak
echo "$FORM_openvpn_client_conf_text" >/etc/openvpn/client.conf
rm -f /etc/openvpn/client.conf.bak
openvpn_cfg_dir="/etc/openvpn"
correct_client_conf "${openvpn_cfg_dir}"
echo "$FORM_openvpn_client_ca_text" | sed -e 's/\r$//g' | head -n -1 >/etc/openvpn/client_ca.crt
echo "$FORM_openvpn_client_cert_text" | sed -e 's/\r$//g' | head -n -1 >/etc/openvpn/client.crt
echo "$FORM_openvpn_client_key_text" | sed -e 's/\r$//g' | head -n -1 >/etc/openvpn/client.key
echo "$FORM_openvpn_client_ta_key_text" | sed -e 's/\r$//g' | head -n -1 >/etc/openvpn/client_ta.key
uci batch <<EOF
set openvpn.custom_config='openvpn'
set openvpn.custom_config.enabled='1'
set openvpn.custom_config.config='/etc/openvpn/client.conf'
set openvpn.custom_config.up='${openvpn_dir}/openvpn.up'
set openvpn.custom_config.down='${openvpn_dir}/openvpn.down'
commit openvpn
-c${openvpn_dir} set openvpn_uci.server.enabled='true'
-c${openvpn_dir} set openvpn_uci.client.enabled='false'
-c${openvpn_dir} set openvpn_uci.client.id='client'
-c${openvpn_dir} commit openvpn_uci
set network.vpn='interface'
set network.vpn.ifname='tun0'
set network.vpn.proto='none'
set network.vpn.defaultroute='0'
set network.vpn.peerdns='0'
commit network
EOF
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/openvpn", "arg": "stop ; /etc/init.d/network restart", "is_daemon": 1, "timeout": 50000}' &> /dev/null
	return
elif [ "${FORM_action}" = "disable_openvpn" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
_Global_SW_mode=$(uci get network.wan._Global_SW_mode 2>/dev/null)
[ -n "$_Global_SW_mode" ] && if ! echo "$_Global_SW_mode" | grep -q "openvpn"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
uci set network.wan._Global_SW_mode=;uci commit network
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Close_OpenVPN_success}!", "jump_url": "/?app=openvpn", "seconds": 2000}
EOF
uci batch <<EOF
set network.vpn=
commit network
set firewall.vpn_zone=
set firewall.vpn_lan_forwarding=
set firewall.ra_openvpn=
set firewall.vpn_wan_forwarding=
commit firewall
set openvpn.custom_config.enabled='0'
commit openvpn
EOF
rm -f ${openvpn_dir}/root.cron
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/openvpn", "arg": "stop ; /etc/init.d/network restart", "is_daemon": 1, "timeout": 50000}' &> /dev/null
	return
elif [ "${FORM_action}" = "clean_keys" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Clear_OpenVPN_Keys_Success}!"}
EOF
	rm -rf /etc/openvpn/*
	return
elif [ "${FORM_action}" = "add_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Generate_client_success}!"}
EOF

eval $(env | grep FORM_data | sed -e 's/^FORM_data\[//g' -e 's/\]=/="/g' -e 's/$/"/g')
uci batch <<EOF
-c${openvpn_dir} set openvpn_uci.${id}=allowed_client
-c${openvpn_dir} set openvpn_uci.${id}.id="${id}"
-c${openvpn_dir} set openvpn_uci.${id}.name="$name"
-c${openvpn_dir} set openvpn_uci.${id}.ip="${ip}"
-c${openvpn_dir} set openvpn_uci.${id}.remote="${remote}"
-c${openvpn_dir} set openvpn_uci.${id}.enabled="$enabled"
-c${openvpn_dir} commit openvpn_uci
EOF
shellgui '{"action": "exec_command", "cmd": "'"${openvpn_dir}"'/openvpn.sbin", "arg": "regenerate_server_and_allowed_clients_from_uci", "is_daemon": 1, "timeout": 50000}' &> /dev/null
return
elif [ "${FORM_action}" = "edit_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Edit_client_success}!"}
EOF
eval $(env | grep FORM_data | sed -e 's/^FORM_data\[//g' -e 's/\]=/="/g' -e 's/$/"/g')
uci batch <<EOF
-c${openvpn_dir} set openvpn_uci.${id}=
-c${openvpn_dir} set openvpn_uci.${id}=allowed_client
-c${openvpn_dir} set openvpn_uci.${id}.id="${id}"
-c${openvpn_dir} set openvpn_uci.${id}.name="$name"
-c${openvpn_dir} set openvpn_uci.${id}.ip="${ip}"
-c${openvpn_dir} set openvpn_uci.${id}.remote="${remote}"
-c${openvpn_dir} set openvpn_uci.${id}.enabled="$enabled"
-c${openvpn_dir} commit openvpn_uci
EOF
shellgui '{"action": "exec_command", "cmd": "'"${openvpn_dir}"'/openvpn.sbin", "arg": "regenerate_server_and_allowed_clients_from_uci", "is_daemon": 1, "timeout": 50000}' &> /dev/null
return
elif [ "${FORM_action}" = "remove_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Del_client_success}!"}
EOF
uci -c${openvpn_dir} set openvpn_uci.${FORM_id}=
uci -c${openvpn_dir} commit openvpn_uci
shellgui '{"action": "exec_command", "cmd": "'"${openvpn_dir}"'/openvpn.sbin", "arg": "regenerate_server_and_allowed_clients_from_uci", "is_daemon": 1, "timeout": 50000}' &> /dev/null
return
fi
}
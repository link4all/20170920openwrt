#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "dhcp_combine" ] &>/dev/null; then
# action: dhcp_combine 绑定一条静态地址绑定
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_dname}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Device}${_LANG_Form_can_not_be_empty}"'"}' && return 1	
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_IP_Address}${_LANG_Form_must_be_IP}"'"}' && return 1	
		shellgui '{"action": "check_mac", "mac": "'"${FORM_mac}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_MAC_Address}${_LANG_Form_must_be_MAC}"'"}' && return 1
	uci batch <<EOF &>/dev/null
add dhcp host
set dhcp.@host[-1]=host
set dhcp.@host[-1].name="${FORM_dname}"
set dhcp.@host[-1].ip=${FORM_ip}
set dhcp.@host[-1].mac=${FORM_mac}
EOF
uci commit dhcp
	cat <<EOF
{"status": 0, "msg": "${FORM_dname} ${_LANG_Form_Combined_You_need_to_restart_the_device}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "dhcp_uncombine" ] &>/dev/null; then
# action: dhcp_uncombine 解绑一条静态地址绑定
	uci set dhcp.${FORM_tag}=
	uci commit dhcp
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Uncombined}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "add_ddns" ] &>/dev/null; then
# action: add_ddns 添加一条 ddns 记录
	for key in domain username password; do
		if [ -z "$(eval echo '$FORM_'${key})" ]; then
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Parameter_incomplete}"}
EOF
			return
		fi
	done
	[ ${FORM_force_interval} -gt 0 ] || FORM_force_interval=0
	[ ${FORM_check_interval} -gt 0 ] || FORM_check_interval=0
	config=$(echo "${FORM_domain}" | sed -e 's/\./_/g' -e 's/-/_/g')
	uci batch <<EOF
set ddns.${config}="service"
set ddns.${config}.service_name="${FORM_service_name}"
set ddns.${config}.domain="${FORM_domain}"
set ddns.${config}.username="${FORM_username}"
set ddns.${config}.password="${FORM_password}"
set ddns.${config}.ip_source='web'
set ddns.${config}.ip_network='wan'
set ddns.${config}.enabled=1
set ddns.${config}.check_interval="${FORM_check_interval}"
set ddns.${config}.check_unit='minutes'
set ddns.${config}.force_interval=${FORM_force_interval}
EOF
	uci commit ddns
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_ddns_record} ${FORM_domain} ${_LANG_Form_successfull_added}"}
EOF
	(/usr/lib/ddns/dynamic_dns_updater.sh ${config} &>/dev/null) &
	return
elif [ "${FORM_action}" = "edit_a_ddns" ] &>/dev/null; then
# action: edit_a_ddns 编辑一条 ddns 记录
	for key in domain username password; do
		if [ -z "$(eval echo '$FORM_'${key})" ]; then
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Parameter_incomplete}"}
EOF
			return
		fi
	done
	[ ${FORM_force_interval} -gt 0 ] || FORM_force_interval=0
	[ ${FORM_check_interval} -gt 0 ] || FORM_check_interval=0
	config=$(echo "${FORM_domain}" | sed -e 's/\./_/g' -e 's/-/_/g')
	uci batch <<EOF
set ddns.${config}.service_name="${FORM_service_name}"
set ddns.${config}.domain="${FORM_domain}"
set ddns.${config}.username="${FORM_username}"
set ddns.${config}.password="${FORM_password}"
set ddns.${config}.ip_source='web'
set ddns.${config}.ip_network='wan'
set ddns.${config}.enabled=1
set ddns.${config}.check_interval="${FORM_check_interval}"
set ddns.${config}.check_unit='minutes'
set ddns.${config}.force_interval=${FORM_force_interval}
EOF
	uci commit ddns
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_ddns_record}${_LANG_Form_successfull_edited}"}
EOF
	(/usr/lib/ddns/dynamic_dns_updater.sh ${config} &>/dev/null) &
	return
elif [ "${FORM_action}" = "del_a_ddns" ] &>/dev/null; then
# action: del_a_ddns 删除一条ddns记录
	uci set ddns.${FORM_config}=
	uci commit ddns
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_ddns_record}${_LANG_Form_successfull_deled}"}
EOF
	return
elif [ "${FORM_action}" = "update_ddns" ] &>/dev/null; then
# action: update_ddns 更新单条 ddns 记录
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_record_updated_time_will_flash_later}"}
EOF
	(/usr/lib/ddns/dynamic_dns_updater.sh ${FORM_config} &>/dev/null) &
	return
elif [ "${FORM_action}" = "edit_portforward" ] &>/dev/null; then
# action: edit_portforward 更新单条 端口转发 记录
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ -z "${FORM_config}" ] && echo '{"status": 0, "msg": "Err"}' && return
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && return 1
		[ $(echo "$FORM_src_dport" | grep -Eo '[0-9]*') = "$FORM_src_dport" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_ExternalPort}${_LANG_Form_must_be_number}"'"}' && return 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && return 1
		[ $(echo "$FORM_dest_port" | grep -Eo '[0-9]*') = "$FORM_dest_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_InternalPort}${_LANG_Form_must_be_number}"'"}' && return 1
	uci batch <<EOF &>/dev/null
set firewall.${FORM_config}.target='DNAT'
set firewall.${FORM_config}.src='wan'
set firewall.${FORM_config}.dest='lan'
set firewall.${FORM_config}.proto="$(echo ${FORM_proto} | tr '+' ' ')"
set firewall.${FORM_config}.src_dport="${FORM_src_dport}"
set firewall.${FORM_config}.dest_ip="${FORM_dest_ip}"
set firewall.${FORM_config}.dest_port="${FORM_dest_port}"
set firewall.${FORM_config}.name="${FORM_name}"
set firewall.${FORM_config}.enabled='1'
EOF
uci commit firewall
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Port_forward_record}${_LANG_Form_successfull_edited}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "new_portforward" ] &>/dev/null; then
# action: new_portforward 添加一条端口转发记录
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && return 1
		[ $(echo "$FORM_src_dport" | grep -Eo '[0-9]*') = "$FORM_src_dport" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_ExternalPort}${_LANG_Form_must_be_number}"'"}' && return 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && return 1
		[ $(echo "$FORM_dest_port" | grep -Eo '[0-9]*') = "$FORM_dest_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_InternalPort}${_LANG_Form_must_be_number}"'"}' && return 1
	uci batch <<EOF &>/dev/null
add firewall redirect
set firewall.@redirect[-1].target='DNAT'
set firewall.@redirect[-1].src='wan'
set firewall.@redirect[-1].dest='lan'
set firewall.@redirect[-1].proto="$(echo ${FORM_proto} | tr '+' ' ')"
set firewall.@redirect[-1].src_dport="${FORM_src_dport}"
set firewall.@redirect[-1].dest_ip="${FORM_dest_ip}"
set firewall.@redirect[-1].dest_port="${FORM_dest_port}"
set firewall.@redirect[-1].name="${FORM_name}"
set firewall.@redirect[-1].enabled='1'
EOF
uci commit firewall
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Port_forward_record}${_LANG_Form_successfull_added}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "del_a_portforward" ] &>/dev/null; then
# action: del_a_portforward 删除一条端口转发记录
	uci set firewall.${FORM_config}=
	uci commit firewall
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Port_forward_record}${_LANG_Form_successfull_deled}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "new_rangeforward" ] &>/dev/null; then
# action: new_rangeforward 添加新的范围端口转发
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && return 1
		[ $(echo "$FORM_start_port" | grep -Eo '[0-9]*') = "$FORM_start_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Start_port}${_LANG_Form_must_be_number}"'"}' && return 1
		[ $(echo "$FORM_end_port" | grep -Eo '[0-9]*') = "$FORM_end_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_End_port}${_LANG_Form_must_be_number}"'"}' && return 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && return 1
	uci batch <<EOF &>/dev/null
add firewall redirect
set firewall.@redirect[-1].target='DNAT'
set firewall.@redirect[-1].src='wan'
set firewall.@redirect[-1].dest='lan'
set firewall.@redirect[-1].proto="$(echo ${FORM_proto} | tr '+' ' ')"
set firewall.@redirect[-1].src_dport="${FORM_start_port}-${FORM_end_port}"
set firewall.@redirect[-1].dest_ip="${FORM_dest_ip}"
set firewall.@redirect[-1].dest_port="${FORM_start_port}-${FORM_end_port}"
set firewall.@redirect[-1].name="${FORM_name}"
set firewall.@redirect[-1].enabled='1'
EOF
uci commit firewall
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ports_forward_record}${_LANG_Form_successfull_added}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "del_a_rangeforward" ] &>/dev/null; then
# action: del_a_rangeforward 删除一个范围端口映射
	uci set firewall.${FORM_config}=
	uci commit firewall
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ports_forward_record}${_LANG_Form_successfull_deled}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "edit_rangeforward" ] &>/dev/null; then
# action: edit_rangeforward 修改范围端口转发
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && return 1
		[ $(echo "$FORM_start_port" | grep -Eo '[0-9]*') = "$FORM_start_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Start_port}${_LANG_Form_must_be_number}"'"}' && return 1
		[ $(echo "$FORM_end_port" | grep -Eo '[0-9]*') = "$FORM_end_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_End_port}${_LANG_Form_must_be_number}"'"}' && return 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && return 1
port_range="${FORM_start_port}-${FORM_end_port}"
uci batch <<EOF
set firewall.${FORM_config}.target='DNAT'
set firewall.${FORM_config}.src='wan'
set firewall.${FORM_config}.dest='lan'
set firewall.${FORM_config}.proto="$(echo ${FORM_proto} | tr '+' ' ')"
set firewall.${FORM_config}.src_dport="${port_range}"
set firewall.${FORM_config}.dest_ip="${FORM_dest_ip}"
set firewall.${FORM_config}.dest_port="$port_range"
set firewall.${FORM_config}.name="${FORM_name}"
set firewall.${FORM_config}.enabled='1'
EOF
uci commit firewall
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ports_forward_record}${_LANG_Form_successfull_edited}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "change_dmzStatus" ] &>/dev/null; then
# action: change_dmzStatus 关闭端口映射
	firewall_str=$(uci show firewall -X)
	echo "$firewall_str" | grep 'proto=.*all' | cut -d '.' -f2 | while read config; do
	uci set firewall.${config}.enabled=0
	done
	uci commit firewall
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "DMZ ${_LANG_Form_Uneffected}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "save_dmzStatus" ] &>/dev/null; then
# action: save_dmzStatus 变更 DMZ 设置(开启)
	firewall_str=$(uci show firewall -X)
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"code": 1, "status": 1, "msg": "'"${_LANG_Form_Internal_IP_address_wrong}"'"}' && return 1
	echo "$firewall_str" | grep 'proto=.*all' | cut -d '.' -f2 | while read config; do
	uci set firewall."${config}"=''
	done
	uci batch <<EOF &>/dev/null
add firewall redirect
set firewall.@redirect[-1].src='wan'
set firewall.@redirect[-1].proto='all'
set firewall.@redirect[-1].dest_ip="$FORM_ip"
set firewall.@redirect[-1].enabled='1'
EOF
uci commit firewall
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_DMZ_take_effect_in} IP: $FORM_ip"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return					
fi
}
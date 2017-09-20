#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "ip_mask_tip" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	shellgui '{"action": "check_ip", "ip": "'"${FORM_ip}"'"}' &>/dev/null
	[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Lan_IP}${_LANG_Form_must_be_IP}"'"}' && return 1	
eval $(ipcalc.sh ${FORM_ip} ${FORM_netmask})
start_ip_prefix=$(echo "$NETWORK" | sed 's#\.[0-9]*$#\.#')
end_ip="$(echo "$BROADCAST" | sed 's#\.[0-9]*$#\.#')$(expr $(echo "$BROADCAST" | cut -d '.' -f4) - 1)"
tmp=$(expr $PREFIX - 24)
tmp=$(expr 8 - $tmp)
max_ips=2
for i in $(seq 2 $tmp); do
max_ips=$(expr $max_ips \* 2)
done
max_ips=$(expr $max_ips - 2)
	cat <<EOF
{ "lanip" : "${FORM_ip}", "start_ip_prefix": "$start_ip_prefix", "end_ip": "$end_ip", "max_ips": $max_ips}
EOF
elif [ "${FORM_action}" = "lan_ip_mask" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Lan_IP}${_LANG_Form_must_be_IP}"'"}' && return 1	
uci set network.${FORM_lan}.ipaddr=${FORM_ip} &>/dev/null
uci set network.${FORM_lan}.netmask=${FORM_netmask} &>/dev/null
uci commit network
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Lan} [${FORM_lan}] ${_LANG_Form_modify_successful}!"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "dhcp_server_switch" ] &>/dev/null; then
	if [ "$(uci get dhcp.${FORM_lanzone})" != "dhcp" ]; then
		if [ ! -f /usr/shellgui/backup/dhcp.${FORM_lanzone} ]; then
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			cat <<EOF
{"status":1,"msg" :"${_LANG_Form_Lan} [${FORM_lanzone}] ${_LANG_Form_does_not_exist}!"}
EOF
			# /etc/init.d/dnsmasq restart &>/dev/null &
			return
		fi
	fi
	if [ $FORM_enabled -eq 0 ]; then
		mkdir -p /usr/shellgui/backup
		uci show dhcp -X | grep 'dhcp\.'${FORM_lanzone}'\.' > /usr/shellgui/backup/dhcp.${FORM_lanzone}
		uci set dhcp.${FORM_lanzone}=
		uci commit dhcp
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		cat <<EOF
{"status":0,"msg" :"${_LANG_Form_Lan} [${FORM_lanzone}] ${_LANG_Form_is_disabled}!"}
EOF
		shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
		return 
	else
		uci set dhcp.${FORM_lanzone}=dhcp
		cat /usr/shellgui/backup/dhcp.${FORM_lanzone} | sed -e "s#'##g" -e 's#"##g' | while read line; do
			uci set ${line}
		done
		uci commit dhcp
		cat <<EOF
{"status":0,"msg" :"${_LANG_Form_Lan} [${FORM_lanzone}] ${_LANG_Form_is_enabled}!"}
EOF
		shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
		return
	fi
elif [ "${FORM_action}" = "lan_dhcp_mask" ] &>/dev/null; then
    printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(echo "$FORM_start" | grep -Eo '[0-9]*') = "$FORM_start" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Start_IP}${_LANG_Form_must_be_number}"'"}' && return 1
		[ $(echo "$FORM_limit" | grep -Eo '[0-9]*') = "$FORM_limit" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_pics}${_LANG_Form_must_be_number}"'"}' && return 1
		[ $(echo "$FORM_leasetime" | grep -Eo '[0-9]*') = "$FORM_leasetime" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Lease}${_LANG_Form_must_be_number}"'"}' && return 1
uci set dhcp.${FORM_lan}=dhcp
uci set dhcp.${FORM_lan}.interface='lan'
uci set dhcp.${FORM_lan}.start=${FORM_start}
uci set dhcp.${FORM_lan}.limit=${FORM_limit}
uci set dhcp.${FORM_lan}.leasetime=${FORM_leasetime}m
uci commit dhcp
    cat <<EOF
{"status":0,"msg" :"${_LANG_Form_Lan} [${FORM_lan}] DHCP ${_LANG_Form_modify_successful}!"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
    return
fi
}

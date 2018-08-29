#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "rm_vwan" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "[$FORM_wan] ${_LANG_Form_removed}","jump_url": "/?app=wan", "seconds": 2000}
EOF
	if uci get network.${FORM_wan} | grep -q 'interface'; then
	uci set network.${FORM_wan}=
	uci commit network
	fi
	return
elif [ "${FORM_action}" = "set_macaddr" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "[$FORM_wan] ${_LANG_Form_Mac} ${_LANG_Form_modified}","jump_url": "/?app=wan", "seconds": 2000}
EOF
	uci set network.${FORM_wan}.macaddr="$FORM_mac"
	uci commit network
	return
elif [ "${FORM_action}" = "clone_nic" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "[$FORM_wan] ${_LANG_Form_Cloned}","jump_url": "/?app=wan", "seconds": 2000}
EOF
network_str=$(uci show network)
ifname=$(uci get network.$FORM_wan.ifname)
num=$(echo "$network_str" | grep -E 'network.v'"${FORM_wan}"'_[0-9]*=interface' | cut -d '=' -f1 | cut -d '.' -f2 | grep -Eo '[0-9]*' | tail -n 1)
num=$((${num:-0} + 1))
uci set network.v${FORM_wan}_${num}=interface
uci set network.v${FORM_wan}_${num}.ifname="v${ifname}_${num}"
if [ $FORM_proto_config -gt 0 ]; then
	uci batch <<EOF
$(echo "$network_str" | grep -E "network\.${FORM_wan}\." | grep -vE 'ifname=|macaddr=' | sed -e 's#network\.'"${FORM_wan}"'\.#network.v'"${FORM_wan}"'_'${num}'\.#g' -e 's/^/set /g')
EOF
else
uci set network.v${FORM_wan}_${num}.proto="dhcp"
fi
	uci commit network
	return
elif [ "${FORM_action}" = "enable_syncppp" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	mpppoe_file='/usr/shellgui/shellguilighttpd/www/apps/wan/mpppoe'
	if [ ${FORM_enabled:-0} -gt 0 ]; then
	touch $mpppoe_file
	enable_str="${_LANG_Form_syncppp} ${_LANG_Form_Enabled}"
	else
	rm -f $mpppoe_file
	enable_str="${_LANG_Form_syncppp} ${_LANG_Form_Disabled}"
	fi
	cat <<EOF
{"status": 0, "msg": "$enable_str"}
EOF
	return
elif [ "${FORM_action}" = "wan_pppoe" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "$FORM_username") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Username}${_LANG_Form_can_not_be_empty}"'"}' && return 1
		[ $(expr length "$FORM_password") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${FORM_password}${_LANG_Form_can_not_be_empty}"'"}' && return 1
		if [ -n "$FORM_mtu" ]; then
		[ $(echo "$FORM_mtu" | grep -Eo '[0-9]*') = "$FORM_mtu" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'MTU "${_LANG_Form_must_be_number}"'"}' && return 1
		fi
		if [ -n "$FORM_dns1" ] || [ -n "$FORM_dns2" ]; then
		for dns in $FORM_dns1 $FORM_dns2; do
			shellgui '{"action": "check_ip", "ip": "'"${dns}"'"}' &>/dev/null
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'DNS "${_LANG_Form_must_be_IP}"'"}' && return 1	
		done
			dns="$FORM_dns1 $FORM_dns2"
		fi
ifname=$(uci get network.${FORM_wan}.ifname)
macaddr=$(uci get network.${FORM_wan}.macaddr)
[ -z "$FORM_metric" ] && FORM_metric=$(uci get network.${FORM_wan}.metric)
uci batch <<EOF
set network.${FORM_wan}=
commit network
set network.${FORM_wan}=interface
set network.${FORM_wan}.ifname="$ifname"
set network.${FORM_wan}.macaddr="$macaddr"
set network.${FORM_wan}.metric="$FORM_metric"
set network.${FORM_wan}.dns="$dns"
set network.${FORM_wan}.proto="pppoe"
set network.${FORM_wan}.username="${FORM_username}"
set network.${FORM_wan}.password="${FORM_password}"
set network.${FORM_wan}.mtu="${FORM_mtu}"
commit network
EOF
	cat <<EOF
{"status": 0, "msg": "[${FORM_wan}] ${_LANG_Form_Port_modify_to_mode} ${_LANG_Form_PPPOE}!"}
EOF
shellgui '{"action": "exec_command", "cmd": "/sbin/ifdown", "arg": "'"${FORM_wan}"';/sbin/ifup '"${FORM_wan}"'", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "wan_dhcp" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		if [ -n "$FORM_dns1" ] || [ -n "$FORM_dns2" ]; then
		for dns in $FORM_dns1 $FORM_dns2; do
			shellgui '{"action": "check_ip", "ip": "'"${dns}"'"}' &>/dev/null
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'DNS "${_LANG_Form_must_be_IP}"'"}' && return 1	
		done
			dns="$FORM_dns1 $FORM_dns2"
		fi
ifname=$(uci get network.${FORM_wan}.ifname)
macaddr=$(uci get network.${FORM_wan}.macaddr)
[ -z "$FORM_metric" ] && FORM_metric=$(uci get network.${FORM_wan}.metric)
uci batch <<EOF
set network.${FORM_wan}=
commit network
set network.${FORM_wan}=interface
set network.${FORM_wan}.ifname="$ifname"
set network.${FORM_wan}.macaddr="$macaddr"
set network.${FORM_wan}.metric="$FORM_metric"
set network.${FORM_wan}.dns="$dns"
set network.${FORM_wan}.proto="dhcp"
commit network
EOF
	cat <<EOF
{"status": 0, "msg": "[${FORM_wan}] ${_LANG_Form_Port_modify_to_mode} ${_LANG_Form_DHCP}!"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/sbin/ifdown", "arg": "'"${FORM_wan}"';/sbin/ifup '"${FORM_wan}"'", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "wan_static" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ipaddr}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_IP_Address}${_LANG_Form_must_be_IP}"'"}' && return 1	
		shellgui '{"action": "check_ip", "ip": "'"${FORM_netmask}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Netmask}${_LANG_Form_must_be_IP}"'"}' && return 1	
		shellgui '{"action": "check_ip", "ip": "'"${FORM_gateway}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Gateway}${_LANG_Form_must_be_IP}"'"}' && return 1	
		if [ -n "$FORM_dns1" ] || [ -n "$FORM_dns2" ]; then
		for dns in $FORM_dns1 $FORM_dns2; do
			shellgui '{"action": "check_ip", "ip": "'"${dns}"'"}' &>/dev/null
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'DNS "${_LANG_Form_must_be_IP}"'"}' && return 1	
		done
			dns="$FORM_dns1 $FORM_dns2"
		fi
ifname=$(uci get network.${FORM_wan}.ifname)
macaddr=$(uci get network.${FORM_wan}.macaddr)
[ -z "$FORM_metric" ] && FORM_metric=$(uci get network.${FORM_wan}.metric)
uci batch <<EOF
set network.${FORM_wan}=
commit network
set network.${FORM_wan}=interface
set network.${FORM_wan}.ifname="$ifname"
set network.${FORM_wan}.macaddr="$macaddr"
set network.${FORM_wan}.metric="$FORM_metric"
set network.${FORM_wan}.dns="$dns"
set network.${FORM_wan}.proto="static"
set network.${FORM_wan}.ipaddr="${FORM_ipaddr}"
set network.${FORM_wan}.netmask="${FORM_netmask}"
set network.${FORM_wan}.gateway="${FORM_gateway}"
commit network
EOF
	cat <<EOF
{"status": 0, "msg": "[${FORM_wan}] ${_LANG_Form_Port_modify_to_mode} ${_LANG_Form_Static}!"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/sbin/ifdown", "arg": "'"${FORM_wan}"';/sbin/ifup '"${FORM_wan}"'", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	return
elif [ "${FORM_action}" = "wan_check_net" ] &>/dev/null; then
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
	type=;ifname=
	eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | sed 's#network\.[a-zA-Z0-9]*\.##g')
	[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans ${ifce}"
done
. /lib/functions/network.sh;
result='{}'
for wan in $wans; do
	network_get_device dev ${wan};network_get_ipaddr wan_ip ${wan};network_get_subnet subnet ${wan};network_get_gateway gateway ${wan};network_get_dnsserver dns ${wan}
	[ -z "${wan_ip}" ] && result=$(echo "$result" | jshon -n {} -i "${wan}" -e "${wan}" -n 1 -i "status" -p -j) && continue
	eval $(ipcalc.sh ${subnet})
	if speed-test --dev ${dev} --delay-only 1 --delay-only-server www.qq.com:80 &>/dev/null; then
	result=$(echo "$result" | jshon -n {} -i "${wan}" -e "${wan}" \
	-n 0 -i "status" \
	-s "${wan_ip}" -i "ip" \
	-s "${NETMASK}" -i "mask" \
	-s "${gateway}" -i "gateway" \
	-s "${dns}" -i "dns" -p -j)
	else
	result=$(echo "$result" | jshon -n {} -i "${wan}" -e "${wan}" \
	-n 1 -i "status" -p -j)
	fi
done
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$result"
	return
fi
}

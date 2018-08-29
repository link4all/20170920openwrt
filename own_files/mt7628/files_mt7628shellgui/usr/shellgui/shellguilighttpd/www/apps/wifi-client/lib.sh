#!/bin/sh

main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "get_nics_sta" ] &>/dev/null; then
wireless_str=$(uci show wireless -X)
nics=$(echo "$wireless_str" | grep '=wifi-device$' | cut -d  '=' -f1 | cut -d '.' -f2)

for nic in $nics; do
num=$(echo "${nic}" | grep -Eo '[0-9]*$')
if [ $(iw phy${num} info | grep -c 'VHT Capabilities') -gt 0 ]; then
	nic_58gs="$nic_5gs $nic"
else
	nic_24gs="$nic_24gs $nic"
fi
done

result_str='{"nic_24gs":{},"nic_58gs":{}}'
for nic in $nic_24gs; do
dev_num=$(echo ${nic} | grep -Eo '[0-9]*$')
scan_str=$(/usr/shellgui/progs/main.sbin wifi_scan wlan${dev_num})
disabled=
eval $(echo "$wireless_str" | grep "^wireless\.${nic}" | grep -v '=wifi-device$' | cut -d '.' -f3-)
[ "$type" != "mac80211" ] && continue
[ -z "$disabled" ] && disabled=0
result_str=$(echo "$result_str" | jshon -e "nic_24gs" -n {} -i "${nic}" -e "${nic}" \
-n ${disabled} -i "disabled" \
-n ${channel} -i "channel" \
-s "${hwmode}" -i "hwmode" \
-p -p -j)
ifaces=$(echo "$wireless_str" | grep '.device=' | sed -e 's#[\"]##g' -e "s#[\']##g" | grep "\.device=${nic}$" | cut -d '.' -f2)
	for iface in $ifaces; do
		network=;mode=;ssid=;encryption=;key=;disabled=;bssid=
		eval $(echo "$wireless_str" | grep -E '^wireless\.'${iface}'\.' | cut -d '.' -f3-)
		[ "$mode" != "sta" ] && continue
		[ -z "$disabled" ] && disabled=0
		result_str=$(echo "$result_str" | jshon -e "nic_24gs" -e "${nic}" -n {} -i "sta" -e "sta" \
		-s "${iface}" -i "iface" \
		-s "${ssid}" -i "ssid" \
		-s "${encryption}" -i "enc" \
		-s "${key}" -i "key" \
		-n ${disabled} -i "disabled" \
		-s "${bssid}" -i "bssid" \
		-p -p -p -j)
		for key in $(seq 0 $(expr $(echo "$scan_str" | jshon -l) - 1)); do
			if [ "$(echo "$scan_str" | jshon -e ${key} -e "bssid" -u)" = "${bssid}" ]; then
			result_str=$(echo "$result_str" | jshon -e "nic_24gs" -e "${nic}" -e "sta" -n $(echo "$scan_str" | jshon -e ${key} -e "sig_p" -u || echo 0) -i "sig_p" -p -p -p -j)
			fi
		done

	done
done
for nic in $nic_58gs; do
dev_num=$(echo ${nic} | grep -Eo '[0-9]*$')
scan_str=$(/usr/shellgui/progs/main.sbin wifi_scan wlan${dev_num})
disabled=
eval $(echo "$wireless_str" | grep "^wireless\.${nic}" | grep -v '=wifi-device$' | cut -d '.' -f3-)
[ "$type" != "mac80211" ] && continue
[ -z "$disabled" ] && disabled=0
result_str=$(echo "$result_str" | jshon -e "nic_58gs" -n {} -i "${nic}" -e "${nic}" \
-n ${disabled} -i "disabled" \
-n ${channel} -i "channel" \
-s "${hwmode}" -i "hwmode" \
-p -p -j)

ifaces=$(echo "$wireless_str" | grep '.device=' | sed -e 's#[\"]##g' -e "s#[\']##g" | grep "\.device=${nic}$" | cut -d '.' -f2)
	for iface in $ifaces; do
		network=;mode=;ssid=;encryption=;key=;disabled=
		eval $(echo "$wireless_str" | grep -E '^wireless\.'${iface}'\.' | cut -d '.' -f3-)
		[ "$mode" != "sta" ] && continue
		[ -z "$disabled" ] && disabled=0
		result_str=$(echo "$result_str" | jshon -e "nic_58gs" -e "${nic}" -n {} -i "sta" \
		-e "sta" -s "${iface}" -i "iface" \
		-s "${ssid}" -i "ssid" \
		-s "${encryption}" -i "enc" \
		-s "${key}" -i "key" \
		-n ${disabled} -i "disabled" \
		-s "${bssid}" -i "bssid" \
		-p -p -j)
		for key in $(seq 0 $(expr $(echo "$scan_str" | jshon -l) - 1)); do
			if [ "$(echo "$scan_str" | jshon -e ${key} -e "bssid" -u)" = "${bssid}" ]; then
			result_str=$(echo "$result_str" | jshon -e "nic_58gs" -e "${nic}" -e "sta" -n $(echo "$scan_str" | jshon -e ${key} -e "sig_p" -u) -i "sig_p" -p -p -p -j)
			fi
		done

	done
done

	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$result_str"
	exit
elif [ "${FORM_action}" = "get_nics_scan" ] &>/dev/null; then
dev=$(echo $FORM_dev | grep -Eo '[0-9]*$')
[ -z "${dev}" ] && echo '{"status": 1, "msg": "error"}' && exit 1
result_str=$(/usr/shellgui/progs/main.sbin wifi_scan wlan${dev})
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$result_str" | jshon -j 2>/dev/null || echo '{"status": 1, "msg": "error"}'
	exit
elif [ "${FORM_action}" = "set_sta" ] &>/dev/null; then
_Global_HW_mode=$(uci get network.wan._Global_HW_mode 2>/dev/null)
[ -n "$_Global_HW_mode" ] && if ! echo "$_Global_HW_mode" | grep -q "wifi-client"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_HW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
wireless_str=$(uci show -X wireless)
network_str=$(uci show -X network)
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if echo "$wireless_str" | grep -qE "wireless\.${FORM_dev}\.type=.*mac80211"; then
		for wifi_iface in $(echo "$wireless_str" | grep -E "wireless\.[a-z0-9]*\.device=[\'|\"]${FORM_dev}[\'|\"]$" | cut -d '.' -f2); do
			echo "$wireless_str" | grep -q "wireless\.${wifi_iface}\.mode=.*sta" && uci set wireless.${wifi_iface}=
		done
if [ "${FORM_enc}" != "none" ]; then
	if [ $(expr length "${FORM_key}") -lt 8 ]; then
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Password_length_not_enough}"}
EOF
	exit
	fi
fi
		wan_zone="wan" #"wwan$(echo ${FORM_dev} | grep -Eo '[0-9]*$')"
		config=$(uci add wireless wifi-iface)
uci set wireless.$FORM_dev.channel=$FORM_channel
uci set wireless.${config}.device="${FORM_dev}"
uci set wireless.${config}.network="$wan_zone"
uci set wireless.${config}.mode='sta'
uci set wireless.${config}.ssid="${FORM_ssid}"
uci set wireless.${config}.bssid="${FORM_bssid}"
uci set wireless.${config}.encryption="${FORM_enc}"
uci set wireless.${config}.key="${FORM_key}"
uci commit wireless

/usr/shellgui/progs/main.sbin wan_dev_bak
_origin_ifname=$(uci get network.wan._origin_ifname)
uci set network.${wan_zone}=
uci set network.${wan_zone}=interface
uci set network.${wan_zone}.proto='dhcp'
uci set network.${wan_zone}._origin_ifname="${_origin_ifname}"
uci set network.${wan_zone}._Global_HW_mode="wifi-client"
# uci set network.${wan_zone}.ifname="wlan$(echo ${FORM_dev} | grep -Eo '[0-9]*$')-1"
uci commit network
# firewall_str=$(uci show -X firewall)
# config=$(echo "$firewall_str" | grep -E "name=[\'|\"]wan[\'|\"]" | cut -d '.' -f2)
# uci get firewall.${config}.network | cut -d '=' -f2- | grep -Eo '[a-z0-9]*' | grep -qE "^${wan_zone}$"
# if [ $? -ne 0 ]; then
	# uci add_list firewall.${config}.network="${wan_zone}"
	# uci commit firewall
# fi
# uci set dhcp.${wan_zone}=
# uci set dhcp.${wan_zone}=dhcp
# uci set dhcp.${wan_zone}.interface="${wan_zone}"
# uci set dhcp.${wan_zone}.ignore='1'
# uci commit dhcp

	cat <<EOF
	{"status": 0, "msg": "${_LANG_Form_Modify_success}", "jump_url": "/?app=wifi-client", "seconds": 2000}
EOF
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
	else
	cat <<EOF
	{"status": 1, "msg": "${FORM_dev} ${_LANG_Form_This_nic_can_not_run_in_sta_mode}"}
EOF
	fi

elif [ "${FORM_action}" = "drop_client" ] &>/dev/null; then
_Global_HW_mode=$(uci get network.wan._Global_HW_mode 2>/dev/null)
[ -n "$_Global_HW_mode" ] && if ! echo "$_Global_HW_mode" | grep -q "wifi-client"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_HW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	wireless_str=$(uci show -X wireless)
	wan_zone="wan"		#"wwan$(echo ${FORM_dev} | grep -Eo '[0-9]*$')"
_origin_ifname=$(uci get network.wan._origin_ifname)
uci set network.${wan_zone}=
uci set network.${wan_zone}=interface
uci set network.${wan_zone}.ifname="${_origin_ifname}"
uci set network.${wan_zone}.proto="dhcp"
uci commit network
	for config_tmp in $(echo "$wireless_str" | grep "device=[\'|\"]${FORM_dev}[\'|\"]" | cut -d '.' -f2); do
		echo "$wireless_str" | grep -q "${config_tmp}\.mode=[\'|\"]sta[\'|\"]" && config=${config_tmp} && break
	done
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ -n "${config}" ]; then
	uci set wireless.${config}=
	uci commit wireless
	# uci set dhcp.${wan_zone}=
	# uci commit dhcp
	# firewall_str=$(uci show -X firewall)
	# config=$(echo "$firewall_str" | grep -E "name=[\'|\"]wan[\'|\"]" | cut -d '.' -f2)
	# wan_olds=$(uci get firewall.${config}.network)
	# if echo "$wan_olds" | cut -d '=' -f2- | grep -Eo '[a-z0-9]*' | grep -qE "^${wan_zone}$"; then
		# uci set firewall.${config}.network=
		# for wan_old in ${wan_olds}; do
		# [ "$wan_old" != "${wan_zone}" ] && uci add_list firewall.${config}.network="${wan_old}"
		# done
		# uci commit firewall
	# fi
	cat <<EOF
	{"status": 0, "msg": "${FORM_dev} ${_LANG_Form_Client_configuration_droped}."}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	else
	cat <<EOF
	{"status": 0, "msg": "${FORM_dev} ${_LANG_Form_Client_configuration_does_not_exist}."}
EOF
	fi
fi
}

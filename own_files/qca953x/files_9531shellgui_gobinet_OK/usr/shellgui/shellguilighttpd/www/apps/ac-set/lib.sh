#!/bin/sh
random_str_cache() {
hexdump -n6 -e'/1 ":%02X"' /dev/random | cut -c2-
}
init_ap_mac_ip() {
ap_mac_ip_str=$(shellgui '{"action": "ac_get_aps_list","only_used":1}' | jshon -a -e Mac -u -p -e IP -u)
}
get_channel() {
jshon -F /tmp/ap.session -e "ap-session" -k | grep -i -m 1 -E "ap/.*_$1"
}
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "get_aps_list" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result_str=$(shellgui '{"action": "ac_get_aps_list"}')
	if [ ${status} -eq 1 ]; then
		printf "[]"
		exit
	else
		printf "${result_str}"
		exit
	fi
elif [ "${FORM_action}" = "flash_ap" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	bak_files=$(echo "$FORM_bak_file" | while read bak_file; do
		printf "${bak_file},"
	done | sed 's/,$//')
	md5=$(md5sum /tmp/firmware-ap.img | cut -d ' ' -f1)
	server_ip=$(jshon -F /usr/shellgui/shellgui.conf -e "mqtt" -e "server_ip" -u)
	server_port=$(grep 'server.port.*' /usr/shellgui/shellguilighttpd/etc/lighttpd/lighttpd.conf | grep -Eo '[0-9]*$')
	echo $md5 >/tmp/ap_fw.md5
	echo "$FORM_ap_list" | while read ap; do
	client_channel=$(get_channel ${ap})
	shellgui '{"action":"pub_cmd","cmd":{"action":"exec_command","cmd":"echo","arg":"\"{\\\"fm_url\\\":\\\"http://'"$server_ip"':'${server_port:-80}'/apps/ac-set/upload.cgi\\\",\\\"md5\\\":\\\"'"$md5"'\\\",\\\"bak_files\\\":\\\"'"$bak_files"'\\\"}\" | /usr/shellgui/shellguilighttpd/www/apps/wire-ap/wire-ap.sbin flash_ap","is_daemon":0,"timeout":50000}, "server_config":{"topic":"'$client_channel'","timeout":3}}' &>/dev/null &
		# ip=$(mac_2_ip ${ap})
		# [ -n "${ip}" ] && cat <<EOF >>/tmp/flash_ap.sh
	done
	cat <<EOF
{"status":0,"msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "restore_ap" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	bak_files=$(echo "$FORM_bak_file" | while read bak_file; do
		printf "${bak_file},"
	done | sed 's/,$//')
	echo "$FORM_ap_list" | while read ap; do
	client_channel=$(get_channel ${ap})
	shellgui '{"action":"pub_cmd","cmd":{"action":"exec_command","cmd":"echo","arg":"\"{\\\"bak_files\\\":\\\"'"$bak_files"'\\\"}\" | /usr/shellgui/shellguilighttpd/www/apps/wire-ap/wire-ap.sbin restore_ap","is_daemon":0,"timeout":50000},"server_config":{"topic":"'$client_channel'","timeout":3}}' &>/dev/null &
	done
	cat <<EOF
{"status":0,"msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "setssid_ap" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$FORM_ap_list" | while read ap; do
	ssid_str=$(echo "${FORM_ssid_24g},${FORM_ssid_58g}" | sed 's/,$//')
shellgui '{"action":"ac_edit_ap","ap_set":{"Mac":"'"${ap}"'","SSID":"'"${ssid_str}"'","Enc":"'"${FORM_enc}"'","Key":"'"${FORM_key}"'"}}' &>/dev/null
client_channel=$(get_channel ${ap})
shellgui '{"action":"pub_ap_change","channel":"'"$client_channel"'"}' &>/dev/null
	done
	cat <<EOF
{"status":0,"msg":"提交成功","jump_url":"/?app=ac-set&action=aplist_cp","seconds":2000}
EOF
	exit
elif [ "${FORM_action}" = "reboot" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$FORM_ap_list" | while read ap; do
	client_channel=$(get_channel ${ap})
	rc="rc/"$(random_str_cache)
result=$(shellgui '{"action":"pub_cmd","cmd":{"action":"exec_command","cmd":"reboot","arg":"","is_daemon":1,"timeout":50000},"server_config":{"topic":"'"$client_channel"'","timeout": 3}}' &>/dev/null)
	done
	cat <<EOF
{"status":0,"msg":"已发送重启"}
EOF
	exit
elif [ "${FORM_action}" = "disable" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$FORM_ap_list" | while read ap; do
shellgui '{"action":"ac_edit_ap","ap_set":{"Mac":"'"${ap}"'","Enabled":0}}' &>/dev/null
client_channel=$(get_channel ${ap})
shellgui '{"action":"pub_ap_change","channel":"'"$client_channel"'"}' &>/dev/null
	done
	cat <<EOF
{"status":0,"msg":"已发送禁用","jump_url":"/?app=ac-set&action=aplist_cp","seconds":2000}
EOF
	exit
elif [ "${FORM_action}" = "enable" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$FORM_ap_list" | while read ap; do
shellgui '{"action":"ac_edit_ap","ap_set":{"Mac":"'"${ap}"'","Enabled":1}}' &>/dev/null
client_channel=$(get_channel ${ap})
shellgui '{"action":"pub_ap_change","channel":"'"$client_channel"'"}' &>/dev/null
	done
	cat <<EOF
{"status":0,"msg":"已发送启用","jump_url":"/?app=ac-set&action=aplist_cp","seconds":2000}
EOF
	exit
elif [ "${FORM_action}" = "get_ap_clients" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_mac}" ] && exit
	client_channel=$(get_channel ${FORM_mac})
	rc="rc/"$(random_str_cache)
result=$(shellgui '{"action":"sub_replay","relay_mqtt":{"topic":"'"${rc}"'"}, "server_config":{"topic":"'"${rc}"'","timeout":3}}' & \
shellgui '{"action":"pub_cmd","cmd":{"action":"exec_command","cmd":"/usr/shellgui/progs/main.sbin","arg":"get_ap_clients wlan0","is_daemon":0,"timeout":50000},"relay_mqtt":{"topic":"'"${rc}"'", "de_enc":1}, "server_config":{"topic":"'"$client_channel"'","timeout":3}}' &>/dev/null)
	result_str=$(echo "$result" | jshon -e "result" -u)
	for mac in $(echo "$result_str" | jshon -k); do
	IP=$(awk '{if("'${mac}'" == $4) {print $1;exit}}' /proc/net/arp)
	[ -n "${IP}" ] && result_str=$(echo "$result_str" | jshon -e "${mac}" -s "${IP}" -i "IP" -p 2>/dev/null)
	done
	echo "$result_str"
	exit
elif [ "${FORM_action}" = "bw_set" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
echo "$FORM_ap_list" | while read mac
do
	client_channel=$(get_channel ${mac})
shellgui '{"action":"ac_edit_ap","ap_set":{"Mac":"'"${mac}"'","Quota_pused":0,"Quota_total":'$(awk 'BEGIN {printf "%d\n",'${FORM_total}'*1073741824}')'}}' &>/dev/null
shellgui '{"action":"pub_ap_change","channel":"'"$client_channel"'"}' &>/dev/null
done
	cat <<EOF
{"status":0,"msg":"带宽总量已设置","jump_url":"/?app=ac-set&action=aplist_cp","seconds":2000}
EOF
	exit
elif [ "${FORM_action}" = "edit_ac" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_mac}" ] && exit
	client_channel=$(get_channel ${FORM_mac})
	rc="rc/"$(random_str_cache)
	ssid=$(echo "$FORM_ssid" | tr '\n' ',' | sed -e 's/,[ ]*$//g' -e 's/,[ ]*$//g' )
if shellgui '{"action":"get_ifces_status"}' | jshon -a -e "ip" -u | grep -qE "^${FORM_ip}$"; then
cat <<EOF
{"status":1,"msg":"编辑失败!IP不可用!"}
EOF
exit
fi
	if shellgui '{"action":"ac_get_aps_list","only_used":1}' | jshon | grep -q "${FORM_mac}"; then
shellgui '{"action":"ac_edit_ap","ap_set":{"Mac":"'"${FORM_mac}"'","Desc":"'"${FORM_desc}"'",
"Model":"'"${FORM_model}"'","Bridge":'${FORM_is_bridge:-0}',"Version":"'"${FORM_version}"'","IP":"'"${FORM_ip}"'","SSID":"'"${ssid}"'","Enc":"'"${FORM_enc}"'","Key":"'"${FORM_key}"'"}}' &>/dev/null
	else
shellgui '{"action":"ac_add_ap_new","ap_set":{"Enabled":1,"Mac":"'"${FORM_mac}"'","Desc":"'"${FORM_desc}"'","Model":"'"${FORM_model}"'","Version":"'"${FORM_ver}"'","IP":"'"${FORM_ip}"'","SSID":"'"${ssid}"'","Enc":"'"${FORM_enc}"'","Key":"'"${FORM_key}"'"}}' &>/dev/null
	fi
shellgui '{"action":"pub_ap_change","channel":"'"$client_channel"'"}' &>/dev/null
cat <<EOF
{"status":0,"msg":"编辑成功!","jump_url":"/?app=ac-set&action=aplist_cp","seconds": 2000}
EOF
exit
elif [ "${FORM_action}" = "kick_out_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_ap_mac}" ] && exit
	client_channel=$(get_channel ${FORM_ap_mac})
	rc="rc/"$(random_str_cache)
result=$(shellgui '{"action": "sub_replay", "relay_mqtt":{"topic":"'"${rc}"'"}, "server_config":{"topic":"'"${rc}"'", "timeout": 3}}' & \
shellgui '{"action": "pub_cmd", "cmd": {"action":"exec_command","cmd":"echo","arg":"\"{\\\"time\\\":60000,\\\"macs\\\":[\\\"'"${FORM_mac}"'\\\"]}\" | \/usr\/shellgui\/progs\/main.sbin kick_out_clients","is_daemon":0,"timeout":50000}, "relay_mqtt":{"topic":"'"${rc}"'","de_enc":1}, "server_config":{"topic":"'$client_channel'", "timeout": 3}}' &>/dev/null)
cat <<EOF
{"status":0,"msg":"踢掉一个用户成功!"}
EOF
exit
elif [ "${FORM_action}" = "kick_out_clients" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_ap_mac}" ] && exit
	client_channel=$(get_channel ${FORM_ap_mac})
	rc="rc/"$(random_str_cache)
	macs=$(echo "$FORM_mac" | tr '\n' ',' | sed -e 's/,[ ]*$//g' -e 's/,[ ]*$//g' )
result=$(shellgui '{"action":"sub_replay","relay_mqtt":{"topic":"'"${rc}"'"}, "server_config":{"topic":"'"${rc}"'","timeout":3}}' & \
shellgui '{"action":"pub_cmd","cmd":{"action":"exec_command","cmd":"echo","arg":"\"{\\\"time\\\":60000,\\\"macs\\\":[\\\"'"${FORM_mac}"'\\\"]}\" | \/usr\/shellgui\/progs\/main.sbin kick_out_clients","is_daemon":0,"timeout":50000},"relay_mqtt":{"topic":"'"${rc}"'","de_enc":1}, "server_config":{"topic":"'"$client_channel"'","timeout":3}}' &>/dev/null)
cat <<EOF
{"status":0,"msg":"踢多个用户成功!"}
EOF
exit
elif [ "${FORM_action}" = "remove" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	shellgui '{"action":"ac_remove_ap","mac":"'"${FORM_mac}"'"}' &>/dev/null
cat <<EOF
{"status":0,"msg":"移除成功!","jump_url":"/?app=ac-set&action=aplist_cp","seconds":2000}
EOF
exit
elif [ "${FORM_action}" = "set_ac" ] &>/dev/null; then
ac_enable_file="/usr/shellgui/shellguilighttpd/www/apps/ac-set/ac.enabled"
ac_is_gateway_file="/usr/shellgui/shellguilighttpd/www/apps/ac-set/ac.is_gateway"
ac_cron_file="/usr/shellgui/shellguilighttpd/www/apps/ac-set/root.cron"
if [ ${FORM_enable_ac_service:-0} -gt 0 ]; then
	touch $ac_enable_file
	cat <<'EOF' >$ac_cron_file
* * * * * /usr/shellgui/shellguilighttpd/www/apps/ac-set/S1200-ac.init keep_file
EOF
else
	rm -f $ac_enable_file $ac_cron_file
fi
if [ ${FORM_is_gateway:-0} -gt 0 ]; then
	touch $ac_is_gateway_file
else
	rm -f $ac_is_gateway_file
fi
shellgui_str=$(jshon -F /usr/shellgui/shellgui.conf)
if [ -n "$shellgui_str" ]; then
	shellgui_str=$(echo "$shellgui_str" | jshon -e "mqtt" -d "username" -d "password" -d "server_port" \
	-n $FORM_mqttsn_port -i "server_port" \
	-s "$FORM_username" -i "username" \
	-s "$FORM_password" -i "password" \
	-p \
	-e "mqtt_sn" -d "server_port" \
	-n $FORM_mqttsn_port -i "server_port" \
	-p)
	. /lib/functions/network.sh
	network_get_ipaddr wanip wan
	network_get_ipaddr lanip lan
	if [ ${FORM_is_gateway:-0} -gt 0 ]; then
		shellgui_str=$(echo "$shellgui_str" | jshon -e "mqtt" -d "server_ip" \
		-s "$lanip" -i "server_ip" -p \
		-e "mqtt_sn" -d "server_ip" \
		-s "$lanip" -i "server_ip" -p)
	else
		shellgui_str=$(echo "$shellgui_str" | jshon -e "mqtt" -d "server_ip" \
		-s "$wanip" -i "server_ip" -p \
		-e "mqtt_sn" -d "server_ip" \
		-s "$wanip" -i "server_ip" -p)
	fi
	echo "$shellgui_str" >/usr/shellgui/shellgui.conf
	/usr/shellgui/shellguilighttpd/www/apps/ac-set/S1200-ac.init restart &>/dev/null
	/etc/init.d/cron restart &>/dev/null
fi
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
{"status":0,"msg":"设置成功!"}
EOF
exit
elif [ "${FORM_action}" = "get_ap_envs" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_mac}" ] && exit
	client_channel=$(get_channel ${FORM_mac})
	rc="rc/"$(random_str_cache)
	shellgui '{"action":"pub_cmd","cmd":{"action":"exec_command","cmd":"/usr/shellgui/shellguilighttpd/www/apps/wire-ap/wire-ap.sbin","arg":"get_ap_envs '"${FORM_hw}"'","is_daemon":0,"timeout":50000},"relay_mqtt":{"topic":"'"${rc}"'", "de_enc":1}, "server_config":{"topic":"'"$client_channel"'","timeout":3}}' &>/dev/null
	sleep 1
	cat /tmp/ap_receive.txt
fi
}

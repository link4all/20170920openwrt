#!/bin/sh

COOKIES_AC_AP_FILE="/tmp/ac_ap.cookie"
MAIN_SBIN='/usr/shellgui/progs/main.sbin'
init_ap_mac_ip() {
ap_mac_ip_str=$(shellgui '{"action": "ac_get_aps_list"}' | jshon -a -e Mac -u -p -e IP -u)
}
mac_2_ip() {
mac="$1"
ip=$(echo "${ap_mac_ip_str}" | sed -nr "/^${mac}$/{n;p}")
[ -n "${ip}" ] && echo "${ip}" || awk '{if("'$mac'" == $4) {print $1;exit}}' /proc/net/arp
}
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "get_aps_list" ] &>/dev/null; then
	# curl -d "app=ac-set&action=get_aps_list" -L "http://10.10.11.254"
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result_str=$(shellgui '{"action": "ac_get_aps_list"}')
	keys=$(echo "${result_str}" | jshon -a -e "Mac" -u)
	status=$(echo "${result_str}" | jshon -e "status" -u)
	result_str=$(echo "${result_str}" | sed 's/]$//')

	if [ ${status} -eq 1 ]; then
		printf "["
		cat /tmp/avable_ap.txt | sort -n | uniq | sed 's/^/,/g' | tr -d '\n' | sed 's/^,//g'
		# "{\"Enc\": \"PSK2-Mixed\",\"Key\": \"1234567897\",\"Uptimes\": 123214,\"Loads_pmem\": 90,\"Loads_pcpu\": 15,\"Clients\": 19,\"Version\": \"1.0.1\", \"IP\": \"10.10.10.15\", \"Mac\": \"00:00:00:00:00:aa\",\"SSID\":\"LONGSSID-Free-2.4g,LONGSSID-Free-5.8g\"}"
		printf "]"
		exit
	else
		printf "${result_str}"
		avable_ap_str=$(cat /tmp/avable_ap.txt)
		for key in ${keys}; do avable_ap_str=$(echo "${avable_ap_str}" | grep -v "${key}");done
		[ -n "${avable_ap_str}" ] && echo "${avable_ap_str}" | sort -n | uniq | sed 's/^/,/g'
		# "{\"Enc\": \"PSK2-Mixed\",\"Key\": \"1234567897\",\"Uptimes\": 123214,\"Loads_pmem\": 90,\"Loads_pcpu\": 15,\"Clients\": 19,\"Version\": \"1.0.1\", \"IP\": \"10.10.10.15\", \"Mac\": \"00:00:00:00:00:aa\",\"SSID\":\"LONGSSID-Free-2.4g,LONGSSID-Free-5.8g\"}"
		printf "]"
		exit
	fi
elif [ "${FORM_action}" = "flash_ap" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo '#!/bin/sh' >/tmp/flash_ap.sh
	bak_files=$(echo "$FORM_bak_file" | while read bak_file; do
		printf "${bak_file},"
	done | sed 's/,$//')
	init_ap_mac_ip
	md5=$(md5sum /tmp/firmware-ap.img | cut -d ' ' -f1)

post_data='{"action":"flash_ap","firmware_md5":"'"${md5}"'","bak_files":"'"${bak_files}"'"}'

	echo "$FORM_ap_list" | while read ap; do
		ip=$(mac_2_ip ${ap})
		[ -n "${ip}" ] && cat <<EOF >>/tmp/flash_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	done
	chmod +x /tmp/flash_ap.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/flash_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "restore_ap" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo '#!/bin/sh' >/tmp/restore_ap.sh
	bak_files=$(echo "$FORM_bak_file" | while read bak_file; do
		printf "${bak_file},"
	done | sed 's/,$//')
	init_ap_mac_ip
post_data='{"action":"restore_ap","bak_files":"'"${bak_files}"'"}'
	echo "$FORM_ap_list" | while read ap; do
		ip=$(mac_2_ip ${ap})
		[ -n "${ip}" ] && cat <<EOF >>/tmp/restore_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	done
	chmod +x /tmp/restore_ap.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/restore_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "setssid_ap" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo '#!/bin/sh' >/tmp/setssid_ap.sh
	init_ap_mac_ip
post_data='{"enc":"'"${FORM_enc}"'","key":"'"${FORM_key}"'","action":"setssid_ap","ssid_24g":"'"${FORM_ssid_24g}"'","ssid_58g":"'"${FORM_ssid_58g}"'"}'
	echo "$FORM_ap_list" | while read ap; do
	ssid_str=$(echo "${FORM_ssid_24g},${FORM_ssid_58g}" | sed 's/,$//')
shellgui '{"action": "ac_edit_ap","ap_set": {"Mac":"'"${ap}"'","SSID":"'"${ssid_str}"'","Enc":"'"${FORM_enc}"'","Key":"'"${FORM_key}"'"}}' &>/dev/null

		ip=$(mac_2_ip ${ap})
		[ -n "${ip}" ] && cat <<EOF >>/tmp/setssid_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	done
	chmod +x /tmp/setssid_ap.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/setssid_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "reboot" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo '#!/bin/sh' >/tmp/reboot_ap.sh
	init_ap_mac_ip
post_data='{"action":"reboot"}'
	echo "$FORM_ap_list" | while read ap; do
		ip=$(mac_2_ip ${ap})
		[ -n "${ip}" ] && cat <<EOF >>/tmp/reboot_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	done
	chmod +x /tmp/reboot_ap.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/reboot_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "disable" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo '#!/bin/sh' >/tmp/disable_ap.sh
	init_ap_mac_ip
post_data='{"action":"disable"}'
	echo "$FORM_ap_list" | while read ap; do
shellgui '{"action": "ac_edit_ap","ap_set": 
{
"Mac":"'"${ap}"'",
"Enabled":0
}
}' &>/dev/null
		ip=$(mac_2_ip ${ap})
		[ -n "${ip}" ] && cat <<EOF >>/tmp/disable_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	done
	chmod +x /tmp/disable_ap.sh

	shellgui '{"action": "exec_command", "cmd": "/tmp/disable_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "enable" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo '#!/bin/sh' >/tmp/enable_ap.sh
	init_ap_mac_ip
post_data='{"action":"enable"}'
	echo "$FORM_ap_list" | while read ap; do
shellgui '{"action": "ac_edit_ap","ap_set": 
{
"Mac":"'"${ap}"'",
"Enabled":1
}
}' &>/dev/null
		ip=$(mac_2_ip ${ap})
		[ -n "${ip}" ] && cat <<EOF >>/tmp/enable_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	done
	chmod +x /tmp/enable_ap.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/enable_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "get_ap_clients" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_mac}" ] && exit
	init_ap_mac_ip
post_data='{"action":"get_ap_clients"}'
	ip=$(mac_2_ip ${FORM_mac})
	echo '#!/bin/sh' >/tmp/get_ap_clients.sh
cat <<EOF >>/tmp/get_ap_clients.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header='Content-Type: application/json' --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	chmod +x /tmp/get_ap_clients.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/get_ap_clients.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	sleep 1
	result_str=$(cat /tmp/ac_ap_work.out)
	for mac in $(jshon -k < /tmp/ac_ap_work.out); do
	IP=$(awk '{if("'${mac}'" == $4) {print $1;exit}}' /proc/net/arp)
	[ -n "${IP}" ] && result_str=$(echo "$result_str" | jshon -e "${mac}" -s "${IP}" -i "IP" -p 2>/dev/null)
	done
	echo "$result_str"
	exit
elif [ "${FORM_action}" = "bw_set" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
echo "$FORM_ap_list" | while read mac
do

shellgui '{"action": "ac_edit_ap","ap_set": 
{
"Mac":"'"${mac}"'",
"Quota_total":'$(expr ${FORM_total} \* 1073741824)'
}
}' &>/dev/null

done
	cat <<EOF
{"status":0, "msg":"提交成功"}
EOF
	exit
elif [ "${FORM_action}" = "edit_ac" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	ssid=$(echo "$FORM_ssid" | tr '\n' ',' | sed -e 's/,[ ]*$//g' -e 's/,[ ]*$//g' )

init_ap_mac_ip
ip=$(mac_2_ip ${FORM_mac})

if shellgui '{"action": "get_ifces_status"}' | jshon -a -e "ip" -u | grep -qE "^${FORM_ip}$"; then
cat <<EOF
{"status":1, "msg":"编辑失败!IP不可用!"}
EOF
exit
fi
post_data='{"action":"edit_ap","ssid":"'"${ssid}"'","ip":"'"${FORM_ip}"'","mac":"'"${FORM_mac}"'","enc":"'"${FORM_enc}"'","key":"'"${FORM_key}"'"}'

cat <<EOF >/tmp/edit_ap.sh
#!/bin/sh
sleep 3
EOF
cat <<EOF >>/tmp/edit_ap.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header='Content-Type: application/json' --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	chmod +x /tmp/edit_ap.sh

	if shellgui '{"action": "ac_get_aps_list"}' | jshon | grep -q "${FORM_mac}"; then

shellgui '{"action": "ac_edit_ap","ap_set": 
{
"Mac":"'"${FORM_mac}"'", 
"Desc":"'"${FORM_desc}"'", 
"Version":"'"${FORM_version}"'",
"IP":"'"${FORM_ip}"'",
"SSID":"'"${ssid}"'",
"Enc":"'"${FORM_enc}"'",
"Key":"'"${FORM_key}"'"
}
}' &>/dev/null

	else

shellgui '{"action": "ac_add_ap_new","ap_set": 
{
"Enabled":1,
"Mac":"'"${FORM_mac}"'", 
"Desc":"'"${FORM_desc}"'", 
"Version":"'"${FORM_ver}"'",
"IP":"'"${FORM_ip}"'",
"SSID":"'"${ssid}"'",
"Enc":"'"${FORM_enc}"'",
"Key":"'"${FORM_key}"'"
}
}' &>/dev/null

	fi

dhcp_str=$(uci show -X dhcp)
old_records=$(echo "$dhcp_str" | grep -E "dhcp\.[a-z0-9]*=host" | grep -Eo 'cfg[a-z0-9]*')

for old_record in $old_records;do
if echo "$dhcp_str" | grep -q "dhcp.${old_record}.mac=[\"|\']${FORM_mac}"; then
uci set dhcp.${old_record}=
fi
done
cfg=$(uci add dhcp host)
uci set dhcp.$cfg=host
uci set dhcp.$cfg.name="AP-$(echo ${FORM_mac} | tr -d ':')"
uci set dhcp.$cfg.ip=${FORM_ip}
uci set dhcp.$cfg.mac=${FORM_mac}
uci commit dhcp
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null

shellgui '{"action": "exec_command", "cmd": "/tmp/edit_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
cat <<EOF
{"status":0, "msg":"编辑成功!", "jump_url": "/?app=ac-set&action=aplist_cp", "seconds": 2000}
EOF
exit
elif [ "${FORM_action}" = "kick_out_client" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_ap_mac}" ] && exit
	init_ap_mac_ip
post_data='{"action":"kick_out_client","client_mac":"'"${FORM_mac}"'"}'
	ip=$(mac_2_ip ${FORM_ap_mac})
	echo '#!/bin/sh' >/tmp/kick_out_client.sh
cat <<EOF >>/tmp/kick_out_client.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	chmod +x /tmp/kick_out_client.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/kick_out_client.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null

cat <<EOF
{"status":0, "msg":"踢掉一个用户成功!"}
EOF
exit
elif [ "${FORM_action}" = "kick_out_clients" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	[ -z "${FORM_ap_mac}" ] && exit
	init_ap_mac_ip
	ip=$(mac_2_ip ${FORM_ap_mac})
	macs=$(echo "$FORM_mac" | tr '\n' ',' | sed -e 's/,[ ]*$//g' -e 's/,[ ]*$//g' )
post_data='{"action":"kick_out_clients","client_macs":"'"${macs}"'"}'
	echo '#!/bin/sh' >/tmp/kick_out_clients.sh
cat <<EOF >>/tmp/kick_out_clients.sh
echo '{"ip":"${ip}","port":64010,"username":"apctrl", "password": "apctrl"}' | ${MAIN_SBIN} login_ap
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=${COOKIES_AC_AP_FILE} "http://${ip}:64010/" -O /tmp/ac_ap_work.out
EOF
	chmod +x /tmp/kick_out_clients.sh
	shellgui '{"action": "exec_command", "cmd": "/tmp/kick_out_clients.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null

cat <<EOF
{"status":0, "msg":"踢多个用户成功!"}
EOF
exit
fi
}

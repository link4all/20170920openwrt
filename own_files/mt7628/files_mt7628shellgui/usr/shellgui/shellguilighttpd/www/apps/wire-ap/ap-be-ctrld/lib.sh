#!/bin/sh

make_sysauth() {
if shellgui "${FORM_body}"; then
new_session="apctrl-"$(cat /proc/sys/kernel/random/uuid | tr -d '-')
shellgui '{"action": "create_session", "session_type": "ap-session", "session": "'"${new_session}"'"}' &>/dev/null
[ -z "$session_expires" ] && session_expires=1036800
	printf "Content-Type: text/html; charset=utf-8\r\nSet-Cookie: session=${new_session}; path=/; expires=$(date -d @$(expr $(date +%s) + $session_expires ) -u '+%A, %d-%b-%y %H:%M:%S') UTC\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "_LANG_Form_Login_success"}
EOF
else
	cat <<EOF
{"status": 1, "msg": "_LANG_Form_Login_fails"}
EOF
fi
}

edit_ap() {
echo "$FORM_body" | jshon -s "${REMOTE_ADDR}" -i "REMOTE_ADDR" -j | /usr/shellgui/progs/main.sbin edit_ap_set
echo "$FORM_body" > /usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap_set.txt
/etc/init.d/firewall disable &>/dev/null
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
}

flash_ap() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
bak_files=$(echo "${FORM_body}" | jshon -e "bak_files" -u)
firmware_md5=$(echo "${FORM_body}" | jshon -e "firmware_md5" -u)


echo "$bak_files" | tr ',' '\n' > /tmp/sysupgrade.conf
post_data='{"action":"get_firmware_ap"}'
cat <<EOF > /tmp/flash_ap.sh
#!/bin/sh
wget -q -T 3 -t 1 --header="Content-Type: application/json" --post-data='${post_data}' --load-cookies=/tmp/ac_ap.cookie "http://${REMOTE_ADDR}:64009/" -O /tmp/firmware.img
md5_str=\$(md5sum /tmp/firmware.img | cut -d ' ' -f1)
if [ "\$md5_str" = "$firmware_md5" ]; then
/usr/shellgui/progs/main.sbin flash_firmware &>/dev/null
fi
EOF
chmod +x /tmp/flash_ap.sh
shellgui '{"action": "exec_command", "cmd": "/tmp/flash_ap.sh", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
}

restore_ap() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
bak_files=$(echo "${FORM_body}" | jshon -e "bak_files" -u)
echo "$bak_files" | tr ',' '\n' > /tmp/sysupgrade.conf
/usr/shellgui/progs/main.sbin first_boot &>/dev/null
	exit
}

setssid_ap() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
echo "$FORM_body" | /usr/shellgui/progs/main.sbin setssid_ap
wifi down;wifi
	exit
}

reboot() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
shellgui '{"action": "exec_command", "cmd": "/sbin/reboot", "arg": "", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
}

disable() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
aplan_type=$(uci get network.aplan.type 2>/dev/null | tr -d '\n')
	if [ "$aplan_type" = "bridge" ]; then
		/usr/shellgui/progs/main.sbin disable_ap_set
		cat <<EOF > /usr/shellgui/shellguilighttpd/www/apps/wire-ap/hotplug/index.html
Disabled
EOF
		shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	fi
	exit
}

enable() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
aplan_type=$(uci get network.aplan.type 2>/dev/null  | tr -d '\n')
	if [ "$aplan_type" != "bridge" ]; then
		cat /usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap_set.txt | /usr/shellgui/progs/main.sbin edit_ap_set
		cat <<EOF > /usr/shellgui/shellguilighttpd/www/apps/wire-ap/hotplug/index.html
Works
EOF
		shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	fi
	exit
}

get_ap_clients() {
printf '{'
iw wlan0 station dump | awk 'BEGIN{ORS=""}
function cover_sig(sig)
{
  if(sig <= -100) {
	sig_result = 0;
  } else if (sig >= -50) {
	sig_result = 100;
  } else {
	sig_result = 2 * (sig + 100);
  }
  return sig_result;
}
/^Station/ { printf "\""$2"\":{" }; 
/signal:/ {printf "\"signal\":"$2","}; 
/signal.*avg:/ {printf("\"signal_avg\":%d,", $3);};
/tx.*bitrate:/ {print "\"tx_bitrate\":"$3",\"signal_pct\":"cover_sig($3)","};  
/rx.*bitrate:/ {print "\"rx_bitrate\":"$3"},"};' | sed 's/,$//'
echo '}'
	exit
}

kick_out_client() {
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF
client_mac=$(echo "$FORM_body" | jshon -e "client_mac" -u)
# <option value="60000">禁用1分钟</option>
# <option value="300000">禁用5分钟</option>
# <option value="1800000">禁用30分钟</option>
# <option value="43200000">禁用12小时</option>
# <option value="86400000">禁用24小时</option>
echo '{"time":60000,"macs":["'"${client_mac}"'"]}' | /usr/shellgui/progs/main.sbin kick_out_clients  &>/dev/null
	exit
}

kick_out_clients() {
env
	cat <<EOF
{"status": 0, "msg": "修改成功"}
EOF

client_macs=$(echo "$FORM_body" | jshon -e "client_macs" -u)
echo "$client_macs" | tr ',' '\n' | while read client_mac; do
echo '{"time":60000,"macs":["'"${client_mac}"'"]}' | /usr/shellgui/progs/main.sbin kick_out_clients  &>/dev/null
done
	exit
}

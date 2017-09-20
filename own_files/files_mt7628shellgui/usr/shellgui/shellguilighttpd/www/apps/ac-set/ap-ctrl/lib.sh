#!/bin/sh

get_firmware_ap() {
cat /tmp/firmware-ap.img | /usr/shellgui/progs/main.sbin http_download firmware.img
}

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

ac_add_ap_new() {
shellgui '{"action": "ac_add_ap_new","ap_set": 
{
	"Mac":"'"${FORM_mac}"'",
	"Version":"'"${FORM_version}"'",
	"Desc":"'"${FORM_desc}"'",
	"IP":"'"${FORM_ip}"'",
	"SSID":"'"${FORM_ssid}"'",
	"Enc":"'"${FORM_enc}"'",
	"Key":"'"${FORM_key}"'"
}
}'
}

ac_edit_ap() {
shellgui '{"action": "ac_edit_ap","ap_set": 
{
"Mac":"'"${FORM_mac}"'", 
"Desc":"'"${FORM_desc}"'", 
"Version":"'"${FORM_version}"'",
"IP":"'"${FORM_ip}"'",
"SSID":"'"${FORM_ssid}"'",
"Enc":"'"${FORM_enc}"'",
"Key":"'"${FORM_key}"'"
}
}'
}

ac_update_ap() {
mac=$(echo "${FORM_body}" | jshon -e "ap_update" -e "Mac" -u)
aps_str=$(shellgui '{"action": "ac_get_aps_list"}' |  jshon -a -e "Mac" -u -p -e "Enabled" -u -p -e "Quota_pused")
echo "$aps_str" | grep -q "${mac}"
if [ $? -ne 0 ]; then
cat <<EOF
{"status":254}
EOF
exit
fi
if [ $(echo "$aps_str" | sed -nr "/${mac}/{n;p}") -eq 0 ]; then
cat <<EOF
{"status":253}
EOF
exit
fi
if [ $(echo "$aps_str" | sed -nr "/${mac}/{n;n;p}") -ge 100 ]; then
cat <<EOF
{"status":252}
EOF
exit
fi
cat <<EOF >> /tmp/ac_update_ap.sh
shellgui '$(echo "${FORM_body}" | jshon -j)'
EOF
cat <<EOF
{"status":0}
EOF
}

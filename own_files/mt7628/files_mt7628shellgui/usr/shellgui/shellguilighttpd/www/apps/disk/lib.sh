#!/bin/sh
uci_show_fstab() {
str_able=$(block detect | sed 's/#option/option/g' >/tmp/fstab_tmp ;uci -c/tmp show -X fstab_tmp; rm -f /tmp/fstab_tmp)
cfgs_able=$(echo "$str_able" | grep '=mount$' | grep -Eo 'cfg[0-9a-z]*')
result='{}'
if [ -n "$cfgs_able" ]; then
for cfg in $cfgs_able; do
vendor=;model=;kernel=;dev_type=;
idVendor=;idProduct=;serial=;bInterfaceNumber=;
class=;class_prog=;subsystem_vendor=;subsystem_device=;bus_id=;
target=;uuid=;device=;label=;type=;options=;enabled=;
	eval $(echo "$str_able" | grep "${cfg}" | cut -d '.' -f3-)
	eval $(/usr/shellgui/progs/main.sbin hd_detect ${device})
	total_size=$(( $total_size * 1024))
	part_size=$(( $part_size * 1024))
	total_size=$(shellgui '{"action": "bit_conver", "bit":'${total_size}'}' | jshon -e "result" -u)
	part_size=$(shellgui '{"action": "bit_conver", "bit":'${part_size}'}' | jshon -e "result" -u)
	vendor=$(echo "${vendor}" | sed 's/[ ]*$//')
	model=$(echo "${model}" | sed 's/[ ]*$//')
	result=$(echo "${result}" | jshon -n {} -i "${uuid}" -e "${uuid}" \
		-s "${uuid}" -i "uuid" \
		-s "${target}" -i "target" \
		-s "${device}" -i "device" \
		-s "${type}" -i "type" \
		-s "${enabled}" -i "enabled" \
		-n {} -i "hwinfo" -e "hwinfo" \
		-s "${vendor}" -i "vendor" \
		-s "${model}" -i "model" \
		-s "${kernel}" -i "kernel" \
		-s "${dev_type}" -i "dev_type" \
		-s "${total_size}" -i "total_size" \
		-s "${part_size}" -i "part_size" \
		-s "${part_size}" -i "part_size" \
		-s "${idVendor}" -i "idVendor" \
		-s "${idProduct}" -i "idProduct" \
		-s "${serial}" -i "serial" \
		-s "${bInterfaceNumber}" -i "bInterfaceNumber" \
		-s "${class}" -i "class" \
		-s "${class_prog}" -i "class_prog" \
		-s "${subsystem_vendor}" -i "subsystem_vendor" \
		-s "${subsystem_device}" -i "subsystem_device" \
		-s "${bus_id}" -i "bus_id" \
		-p -p -j)
label=$(echo "${label}" | grep -Eo '[0-9a-z_- ]*' 2>&-) && result=$(echo "${result}" | jshon -e "${uuid}" \
		-s "${label}" -i "label" -p -j)
[ -n "${options}" ] && result=$(echo "${result}" | jshon -e "${uuid}" \
		-s "${options}" -i "options" \
		-p -j)
done

str_eft=$(uci show fstab -X)
	if [ -n "$str_eft" ]; then
cfgs_eft=$(echo "$str_eft" | grep -E '\.uuid=' | cut -d '.' -f2)
eval $(echo "$str_eft" | grep -E '\.uuid=|\.target=|\.enabled=' | sed -e 's#^fstab\.##g' -e 's#\.uuid=#_uuid=#g' -e 's#\.target=#_target=#g' -e 's#\.enabled=#_enabled=#g')
for cfg in $cfgs_eft; do
uuid=$(eval echo '$'${cfg}_uuid)
enabled=$(eval echo '$'${cfg}_enabled)
target=$(eval echo '$'${cfg}_target)
[ ${enabled} -ge 0 ] && result=$(echo "${result}" | jshon -e "${uuid}" -d enabled -s "${enabled}" -i enabled -p -j)
[ -n "${target}" ] && result=$(echo "${result}" | jshon -e "${uuid}" -d  target -s "${target}" -i  target -p -j)
done
	fi
else
	echo '{}';return
fi
uuid_device_str=$(echo "$result" | jshon -a -e "uuid" -u -p -e "device" -u)
df_result=$(df -h $(echo "$result" | jshon -a -e "device" -u | tr '\n' ' ') 2>&- | grep -v '^Filesystem')
if [ -n "$df_result" ]; then
result=$(echo "$df_result" | while read fs size used ava used_pct mounted_on; do
[ -n "${fs}" ] || continue
uuid=$(echo "$uuid_device_str" | sed -n "{\#${fs}\$#{g;p}};h")
result=$(echo "${result}" | jshon -e "${uuid}" \
	-d size -s "${size}" -i size \
	-d used -s "${used}" -i used \
	-d ava -s "${ava}" -i ava \
	-d used_pct -s "${used_pct}" -i used_pct \
	-d mounted_on -s "${mounted_on}" -i mounted_on \
	-p -j)
echo "$result"
done | tail -n1)
fi
echo "$result"
}
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "show_fstab" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	uci_show_fstab
	return
elif [ "${FORM_action}" = "disk_setting" ] &>/dev/null; then
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_success}"}
EOF

nums=$(env | grep ^FORM_data | sed -e 's/^FORM_data\[//g' -e 's/\]\[.*//g' | sort -n | uniq)
eval $(env | grep ^FORM_data | sed -e 's/^FORM_data\[/disk_/g' -e 's/\]\[/_/g' -e 's/\]=/="/g' -e 's/$/"/g')

rm -f /etc/config/fstab;touch /etc/config/fstab
uci batch <<EOF &>/dev/null
add fstab global
set fstab.@global[-1].anon_swap='0'
set fstab.@global[-1].anon_mount='0'
set fstab.@global[-1].auto_swap='1'
set fstab.@global[-1].auto_mount='1'
set fstab.@global[-1].delay_root='5'
set fstab.@global[-1].check_fs='0'
EOF
for num in $nums;do
uuid=;target=;enabled=;options=;
uuid=$(eval echo '${disk_'${num}'_uuid}')
target=$(eval echo '${disk_'${num}'_target}')
enabled=$(eval echo '${disk_'${num}'_enabled}')
options=$(eval echo '${disk_'${num}'_options}')
uci batch <<EOF &>/dev/null
add fstab mount
set fstab.@mount[-1].uuid='${uuid}'
set fstab.@mount[-1].target='${target}'
set fstab.@mount[-1].enabled='${enabled}'
set fstab.@mount[-1].options='${options}'
EOF
done
uci commit fstab
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/fstab", "arg": "restart", "is_daemon": 1, "timeout": 50000}' &>/dev/null
	return
fi
}

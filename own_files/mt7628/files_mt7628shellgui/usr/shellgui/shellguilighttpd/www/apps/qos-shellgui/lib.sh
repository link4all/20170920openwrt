#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "get_upload_speed" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
tc -s class show dev $FORM_wan
elif [ "${FORM_action}" = "get_download_speed" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
tc -s class show dev imq0
elif [ "${FORM_action}" = "get_bandwidth" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ -n "$FORM_monitor" ]; then
		date -u "+%s"
		for id in $FORM_monitor; do
			bw-gain -i "$id" -h -m
		done
	fi
return
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "set_download" ] &>/dev/null; then
env_str=$(env | grep FORM_ | sort -n)
qos_str=$(uci show qos_shellgui)
class_rule_configs_str=$(echo "$qos_str" | grep -E 'qos_shellgui.download_rule_.*=download_rule|qos_shellgui.dclass_.*=download_class' | cut -d '=' -f1)
for class_num in $(echo "$class_rule_configs_str" | grep '^qos_shellgui\.dclass_' | grep -Eo '[0-9]*$'); do
uci del qos_shellgui.dclass_${class_num}
done
for rule_num in $(echo "$class_rule_configs_str" | grep '^qos_shellgui\.download_rule_' | grep -Eo '[0-9]*$'); do
uci del qos_shellgui.download_rule_${rule_num}
done
classs_num=$(echo "$env_str" | grep -Eo 'FORM_class_data\[[0-9]*' | grep -Eo '[0-9]*' | sort -n | uniq)
for class_num in $classs_num; do
name=;percent=;min_bw=;max_bw=;minRTT=;
	eval $(echo "$env_str" | grep -E 'FORM_class_data\['${class_num}'\]' | cut -d '[' -f3- | tr -d ']')
class_num=$(expr ${class_num} + 1)
uci set qos_shellgui.dclass_${class_num}="download_class"
uci set qos_shellgui.dclass_${class_num}.name="${name}"
uci set qos_shellgui.dclass_${class_num}.percent_bandwidth="${percent}"
[ ${min_bw} -gt 0 ] && uci set qos_shellgui.dclass_${class_num}.min_bandwidth="${min_bw}"
[ ${max_bw} -gt 0 ] && uci set qos_shellgui.dclass_${class_num}.max_bandwidth="${max_bw}"
uci set qos_shellgui.dclass_${class_num}.minRTT="${minRTT}"
done
rules_num=$(echo "$env_str" | grep -Eo 'FORM_rule_data\[[0-9]*' | grep -Eo '[0-9]*' | sort -n | uniq)
for rule_num in $rules_num; do
class=;test_order=;srcport=;connbytes_kb=;source=;destination=;dstport=;max_pkt_size=;min_pkt_size=;proto=;layer7=;
	eval $(echo "$env_str" | grep -E 'FORM_rule_data\['${rule_num}'\]' | cut -d '[' -f3- | tr -d ']')
	rule_num=$(expr ${rule_num} + 1)
	num_rule=$(expr ${rule_num} \* 100)
uci batch <<EOF
set qos_shellgui.download_rule_${num_rule}="download_rule"
set qos_shellgui.download_rule_${num_rule}.class="${class}"
set qos_shellgui.download_rule_${num_rule}.test_order="${test_order}"
set qos_shellgui.download_rule_${num_rule}.srcport="${srcport}"
set qos_shellgui.download_rule_${num_rule}.connbytes_kb="${connbytes_kb}"
set qos_shellgui.download_rule_${num_rule}.source="${source}"
set qos_shellgui.download_rule_${num_rule}.destination="${destination}"
set qos_shellgui.download_rule_${num_rule}.dstport="${dstport}"
set qos_shellgui.download_rule_${num_rule}.max_pkt_size=${max_pkt_size}
set qos_shellgui.download_rule_${num_rule}.min_pkt_size=${min_pkt_size}
set qos_shellgui.download_rule_${num_rule}.proto="${proto}"
set qos_shellgui.download_rule_${num_rule}.layer7="${layer7}"
EOF
done
uci batch <<EOF
set qos_shellgui.download.qos_monenabled="${FORM_qos_monenabled}"
set qos_shellgui.download.ptarget_ip="${FORM_ptarget_ip}"
set qos_shellgui.download.pinglimit="${FORM_pinglimit}"
set qos_shellgui.download.default_class="${FORM_download_default_class}"
set qos_shellgui.download.total_bandwidth="${POST_download_total_bandwidth}"
commit qos_shellgui
EOF
/usr/shellgui/progs/bwmond stop &>/dev/null
/usr/shellgui/progs/qos_shellgui stop &>/dev/null
[ -d /usr/data/bwmon/ ] && rm -rf /usr/data/bwmon/qos-download-* &>/dev/null
[ -d /tmp/data/bwmon/ ] && rm -rf /tmp/data/bwmon/qos-download-* &>/dev/null
/etc/init.d/firewall restart &>/dev/null
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
return
elif [ "${FORM_action}" = "set_upload" ] &>/dev/null; then
env_str=$(env | grep FORM_ | sort -n)

qos_str=$(uci show qos_shellgui)
class_rule_configs_str=$(echo "$qos_str" | grep -E 'qos_shellgui.upload_rule_.*=upload_rule|qos_shellgui.uclass_.*=upload_class' | cut -d '=' -f1)
for class_num in $(echo "$class_rule_configs_str" | grep '^qos_shellgui\.uclass_' | grep -Eo '[0-9]*$'); do
uci del qos_shellgui.uclass_${class_num}
done
for rule_num in $(echo "$class_rule_configs_str" | grep '^qos_shellgui\.upload_rule_' | grep -Eo '[0-9]*$'); do
uci del qos_shellgui.upload_rule_${rule_num}
done
classs_num=$(echo "$env_str" | grep -Eo 'FORM_class_data\[[0-9]*' | grep -Eo '[0-9]*' | sort -n | uniq)
for class_num in $classs_num; do
name=;percent=;min_bw=;max_bw=;
# minRTT=;
	eval $(echo "$env_str" | grep -E 'FORM_class_data\['${class_num}'\]' | cut -d '[' -f3- | tr -d ']')
class_num=$(expr ${class_num} + 1)
uci set qos_shellgui.uclass_${class_num}="upload_class"
uci set qos_shellgui.uclass_${class_num}.name="${name}"
uci set qos_shellgui.uclass_${class_num}.percent_bandwidth="${percent}"
[ ${min_bw} -gt 0 ] && uci set qos_shellgui.uclass_${class_num}.min_bandwidth="${min_bw}"
[ ${max_bw} -gt 0 ] && uci set qos_shellgui.uclass_${class_num}.max_bandwidth="${max_bw}"
# uci set qos_shellgui.uclass_${class_num}.minRTT="${minRTT}"
done
rules_num=$(echo "$env_str" | grep -Eo 'FORM_rule_data\[[0-9]*' | grep -Eo '[0-9]*' | sort -n | uniq)
for rule_num in $rules_num; do
class=;test_order=;srcport=;connbytes_kb=;source=;destination=;dstport=;max_pkt_size=;min_pkt_size=;proto=;layer7=;
	eval $(echo "$env_str" | grep -E 'FORM_rule_data\['${rule_num}'\]' | cut -d '[' -f3- | tr -d ']')
	rule_num=$(expr ${rule_num} + 1)
	num_rule=$(expr ${rule_num} \* 100)
uci batch <<EOF
set qos_shellgui.upload_rule_${num_rule}="upload_rule"
set qos_shellgui.upload_rule_${num_rule}.class="${class}"
set qos_shellgui.upload_rule_${num_rule}.test_order="${test_order}"
set qos_shellgui.upload_rule_${num_rule}.srcport="${srcport}"
set qos_shellgui.upload_rule_${num_rule}.connbytes_kb="${connbytes_kb}"
set qos_shellgui.upload_rule_${num_rule}.source="${source}"
set qos_shellgui.upload_rule_${num_rule}.destination="${destination}"
set qos_shellgui.upload_rule_${num_rule}.dstport="${dstport}"
set qos_shellgui.upload_rule_${num_rule}.max_pkt_size=${max_pkt_size}
set qos_shellgui.upload_rule_${num_rule}.min_pkt_size=${min_pkt_size}
set qos_shellgui.upload_rule_${num_rule}.proto="${proto}"
set qos_shellgui.upload_rule_${num_rule}.layer7="${layer7}"
EOF
done
# uci set qos_shellgui.upload.qos_monenabled="${FORM_qos_monenabled}"
# uci set qos_shellgui.upload.ptarget_ip="${FORM_ptarget_ip}"
# uci set qos_shellgui.upload.pinglimit="${FORM_pinglimit}"
uci set qos_shellgui.upload.default_class="${FORM_upload_default_class}"
uci set qos_shellgui.upload.total_bandwidth="${POST_upload_total_bandwidth}"
uci commit qos_shellgui
/usr/shellgui/progs/bwmond stop &>/dev/null
/usr/shellgui/progs/qos_shellgui stop &>/dev/null
[ -d /usr/data/bwmon/ ] && rm -rf /usr/data/bwmon/qos-upload-* &>/dev/null
[ -d /tmp/data/bwmon/ ] && rm -rf /tmp/data/bwmon/qos-upload-* &>/dev/null
/etc/init.d/firewall restart &>/dev/null
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
return
elif [ "${FORM_action}" = "total_bandwidth" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ ${FORM_total_bw} -gt 0 ];then
	cat <<EOF
{"status":0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
		if [ "${FORM_up_down}" = "all" ]; then
			uci set qos_shellgui.upload.total_bandwidth=512
			uci set qos_shellgui.download.total_bandwidth=6600
		else
uci set qos_shellgui.${FORM_up_down}.total_bandwidth=${FORM_total_bw}
		fi
	else
		if [ "${FORM_up_down}" = "all" ]; then
			uci del qos_shellgui.upload.total_bandwidth
			uci del qos_shellgui.download.total_bandwidth
		else
uci del qos_shellgui.${FORM_up_down}.total_bandwidth
		fi
	cat <<EOF
{"status":0, "msg": "${_LANG_Form_Disabled}!"}
EOF
uci commit qos_shellgui
	fi
	if [ "${FORM_up_down}" = "all" ]; then
	shellgui '{"action": "exec_command", "cmd": "/usr/shellgui/progs/main.sbin", "arg": "restart_qos all", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	else
	shellgui '{"action": "exec_command", "cmd": "/usr/shellgui/progs/main.sbin", "arg": "restart_qos '"${FORM_up_down}"'", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	fi
elif [ "${FORM_action}" = "get_qos_download" ] &>/dev/null; then
qos_str=$(uci show -X qos_shellgui)
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
class_str='[]'
classes=$(echo "$qos_str" | grep '=download_class$' | cut -d '=' -f1 | grep -Eo '[0-9]*$')
for class in $classes; do
name=;percent_bandwidth=;min_bandwidth=;max_bandwidth=;minRTT=
eval $(echo "$qos_str" | grep '^qos_shellgui\.dclass_'${class}'\.' | cut -d '.' -f3-)
class_str=$(echo "$class_str" | jshon -n {} -i append -e -1 \
	-s "$name" -i "name" \
	-s "$minRTT" -i "minRTT" \
	-n "$class" -i "class" \
	-n "$percent_bandwidth" -i "percent" \
	-n "$min_bandwidth" -i "min_bw" \
	-n "$max_bandwidth" -i "max_bw" \
	-p -j)
done
rule_str='[]'
rules=$(echo "$qos_str" | grep '=download_rule$' | cut -d '=' -f1 | grep -Eo '[0-9]*$')
for rule in $rules; do
class=;test_order=;srcport=;connbytes_kb=;source=;destination=;dstport=;max_pkt_size=;min_pkt_size=;proto=;layer7=;
eval $(echo "$qos_str" | grep '^qos_shellgui\.download_rule_'${rule}'\.' | cut -d '.' -f3-)
rule_str=$(echo "$rule_str" | jshon -n {} -i append -e -1 \
	-s "$class" -i "class" \
	-n "$test_order" -i "test_order" \
	-n "$srcport" -i "srcport" \
	-n "$connbytes_kb" -i "connbytes_kb" \
	-s "$source" -i "source" \
	-s "$destination" -i "destination" \
	-n "$dstport" -i "dstport" \
	-n "$max_pkt_size" -i "max_pkt_size" \
	-n "$min_pkt_size" -i "min_pkt_size" \
	-s "$proto" -i "proto" \
	-s "$layer7" -i "layer7" \
	-p -j)
done
eval $(echo "$qos_str" | grep -E '^qos_shellgui.download.default_class=|qos_shellgui.download.total_bandwidth=|qos_shellgui.download.qos_monenabled=|qos_shellgui.download.ptarget_ip=|qos_shellgui.download.pinglimit=' | cut -d '.' -f3-)
echo '{"download_default_class": "'${default_class}'", "download_total_bandwidth": "'${total_bandwidth}'", "class_data":'"$class_str"', "rule_data": '"$rule_str"', "qos_monenabled": "'"${qos_monenabled}"'", "ptarget_ip": "'"${ptarget_ip}"'", "pinglimit": "'"${pinglimit}"'"}'
return
elif [ "${FORM_action}" = "get_qos_upload" ] &>/dev/null; then
qos_str=$(uci show -X qos_shellgui)
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
class_str='[]'
classes=$(echo "$qos_str" | grep '=upload_class$' | cut -d '=' -f1 | grep -Eo '[0-9]*$')
for class in $classes; do
name=;percent_bandwidth=;min_bandwidth=;max_bandwidth=;
eval $(echo "$qos_str" | grep '^qos_shellgui\.uclass_'${class}'\.' | cut -d '.' -f3-)
class_str=$(echo "$class_str" | jshon -n {} -i append -e -1 \
	-s "$name" -i "name" \
	-n "$class" -i "class" \
	-n "$percent_bandwidth" -i "percent" \
	-n "$min_bandwidth" -i "min_bw" \
	-n "$max_bandwidth" -i "max_bw" \
	-p -j)
done
rule_str='[]'
rules=$(echo "$qos_str" | grep '=upload_rule$' | cut -d '=' -f1 | grep -Eo '[0-9]*$')
for rule in $rules; do
class=;test_order=;srcport=;connbytes_kb=;source=;destination=;dstport=;max_pkt_size=;min_pkt_size=;proto=;layer7=;
eval $(echo "$qos_str" | grep '^qos_shellgui\.upload_rule_'${rule}'\.' | cut -d '.' -f3-)
rule_str=$(echo "$rule_str" | jshon -n {} -i append -e -1 \
	-s "$class" -i "class" \
	-n "$test_order" -i "test_order" \
	-n "$srcport" -i "srcport" \
	-n "$connbytes_kb" -i "connbytes_kb" \
	-s "$source" -i "source" \
	-s "$destination" -i "destination" \
	-n "$dstport" -i "dstport" \
	-n "$max_pkt_size" -i "max_pkt_size" \
	-n "$min_pkt_size" -i "min_pkt_size" \
	-s "$proto" -i "proto" \
	-s "$layer7" -i "layer7" \
	-p -j)
done
eval $(echo "$qos_str" | grep -E '^qos_shellgui.upload.default_class=|qos_shellgui.upload.total_bandwidth=' | cut -d '.' -f3-)
echo '{"upload_default_class": "'${default_class}'", "upload_total_bandwidth": "'${total_bandwidth}'", "class_data":'"$class_str"', "rule_data": '"$rule_str"'}'
return
elif [ "${FORM_action}" = "use_wan" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0, "msg": "${_LANG_Form_QoS_Extranet_network_set_to} ${FORM_network}", "jump_url": "/?app=qos-shellgui", "seconds": 10000}
EOF
uci set qos_shellgui.global.network="${FORM_network}"
uci set qos_shellgui.global.interface="$(uci get network.${FORM_network}.ifname)"
uci commit qos_shellgui
shellgui '{"action": "exec_command", "cmd": "/usr/shellgui/progs/main.sbin", "arg": "restart_qos '"${FORM_up_down}"'", "is_daemon": 1, "timeout": 100000}' &>/dev/null
return
fi
}
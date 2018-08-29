#!/bin/sh
quotas_dir="/usr/shellgui/shellguilighttpd/www/apps/quotas"
get_quotas() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
p_quotas | grep "\"${REMOTE_ADDR}\"";return
}
main() {
[ "${FORM_action}" = "get_quotas" ] && get_quotas
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "quotas_status" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
p_quotas
echo "Success"
return
elif [ "${FORM_action}" = "quotas_save_change" ] &>/dev/null; then
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
for old_num in $(uci -c${quotas_dir} show quotas_uci | grep '=quota$' | grep -Eo '[0-9]*'); do
uci -c${quotas_dir} del quotas_uci.quota_${old_num}
done &>/dev/null
uci -c${quotas_dir} commit quotas_uci
for num in $(env | grep -Eo 'FORM_quots\[[0-9]*\]' | sort -n | uniq | grep -Eo '[0-9]*'); do
id=;reset_interval=;exceeded_down_speed=;onpeak_weekdays=;offpeak_weekly_ranges=;exceeded_up_class_mark=;combined_limit=;ingress_limit=;egress_limit=;onpeak_hours=;offpeak_weekdays=;exceeded_down_class_mark=;enabled=;exceeded_up_speed=;onpeak_weekly_ranges=;reset_time=;ip=;offpeak_hours=;
eval $(env | grep -E "FORM_quots\[${num}\]" | sed -e 's#^.*\]\[##g' -e 's#\]=#=\"#g' -e 's#$#\"#g')
cfg_num=$((${num} + 1))
uci -c${quotas_dir} set quotas_uci.quota_${cfg_num}='quota'
	for option in id reset_interval exceeded_down_speed onpeak_weekdays offpeak_weekly_ranges exceeded_up_class_mark combined_limit ingress_limit egress_limit onpeak_hours offpeak_weekdays exceeded_down_class_mark enabled exceeded_up_speed onpeak_weekly_ranges reset_time ip offpeak_hours; do
	uci -c${quotas_dir} set quotas_uci.quota_${cfg_num}.${option}="$(eval echo '$'${option})"
	done
done
uci -c${quotas_dir} commit quotas_uci
shellgui '{"action":"exec_command","cmd":"/etc/init.d/firewall","arg":"restart","is_daemon":1,"timeout":100000}' &>/dev/null
[ -d "/usr/data/quotas/" ] && rm -rf /usr/data/quotas/* && b_quotas
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_Successful}!"}
EOF
	return
elif [ "${FORM_action}" = "qos_class_enabled" ] &>/dev/null; then
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
[ $FORM_qos_class_enabled -gt 0 ] && touch ${quotas_dir}/qos_class_enabled || rm -f ${quotas_dir}/qos_class_enabled
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_Successful}!"}
EOF
	return
fi
}

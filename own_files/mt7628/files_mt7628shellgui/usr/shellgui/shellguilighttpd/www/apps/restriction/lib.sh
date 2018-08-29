#!/bin/sh
restriction_dir="/usr/shellgui/shellguilighttpd/www/apps/restriction"
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "restriction_save_change" ] &>/dev/null; then
for old_cfg in $(uci -c${restriction_dir} show restriction_uci | grep -E '=restriction_rule$|=whitelist_rule$' | sed -e 's/=.*$//g' -e 's/restriction_uci\.//g'); do
uci -c${restriction_dir} del restriction_uci.${old_cfg}
done &>/dev/null
uci -c${restriction_dir} commit restriction_uci
for num in $(env | grep -Eo 'FORM_restriction_rule\[[0-9]*\]' | sort -n | uniq | grep -Eo '[0-9]*'); do
active_hours=;active_weekdays=;active_weekly_ranges=;app_proto=;description=;enabled=;id=;local_addr=;local_port=;not_app_proto=;not_local_addr=;not_local_port=;not_remote_addr=;not_remote_port=;not_url_contains=;not_url_domain_contains=;not_url_domain_exact=;not_url_domain_regex=;not_url_exact=;not_url_regex=;proto=;remote_addr=;remote_port=;url_contains=;url_domain_contains=;url_domain_exact=;url_domain_regex=;url_exact=;url_regex=;
eval $(env | grep -E "FORM_restriction_rule\[${num}\]" | sed -e 's#^.*\]\[##g' -e 's#\]=#=\"#g' -e 's#$#\"#g')
cfg_num=$((${num} + 1))
uci -c${restriction_dir} set restriction_uci.rule_${cfg_num}='restriction_rule'
	for option in active_hours active_weekdays active_weekly_ranges app_proto description enabled id local_addr local_port not_app_proto not_local_addr not_local_port not_remote_addr not_remote_port not_url_contains not_url_domain_contains not_url_domain_exact not_url_domain_regex not_url_exact not_url_regex proto remote_addr remote_port url_contains url_domain_contains url_domain_exact url_domain_regex url_exact url_regex; do
	uci -c${restriction_dir} set restriction_uci.rule_${cfg_num}.${option}="$(eval echo '$'${option})"
	done
done
uci -c${restriction_dir} commit restriction_uci
for num in $(env | grep -Eo 'FORM_whitelist_rule\[[0-9]*\]' | sort -n | uniq | grep -Eo '[0-9]*'); do
active_hours=;active_weekdays=;active_weekly_ranges=;app_proto=;description=;enabled=;id=;local_addr=;local_port=;not_app_proto=;not_local_addr=;not_local_port=;not_remote_addr=;not_remote_port=;not_url_contains=;not_url_domain_contains=;not_url_domain_exact=;not_url_domain_regex=;not_url_exact=;not_url_regex=;proto=;remote_addr=;remote_port=;url_contains=;url_domain_contains=;url_domain_exact=;url_domain_regex=;url_exact=;url_regex=;
eval $(env | grep -E "FORM_whitelist_rule\[${num}\]" | sed -e 's#^.*\]\[##g' -e 's#\]=#=\"#g' -e 's#$#\"#g')
cfg_num=$((${num} + 1))
uci -c${restriction_dir} set restriction_uci.exception_${cfg_num}='whitelist_rule'
	for option in active_hours active_weekdays active_weekly_ranges app_proto description enabled id local_addr local_port not_app_proto not_local_addr not_local_port not_remote_addr not_remote_port not_url_contains not_url_domain_contains not_url_domain_exact not_url_domain_regex not_url_exact not_url_regex proto remote_addr remote_port url_contains url_domain_contains url_domain_exact url_domain_regex url_exact url_regex; do
	uci -c${restriction_dir} set restriction_uci.exception_${cfg_num}.${option}="$(eval echo '$'${option})"
	done
done
uci -c${restriction_dir} commit restriction_uci
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
	return
fi
}

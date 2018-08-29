#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "net_record_server_visit_count" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result_str=$(shellgui '{"action": "net_record_server_visit_count", "per_page_records": '$FORM_per_page_records'}')
	echo "$result_str" | jshon -j || echo '{"status": 1,"msg": "Err"}'
	return
elif [ "${FORM_action}" = "net_record_search_keyword_count" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result_str=$(shellgui '{"action": "net_record_search_keyword_count", "per_page_records": '$FORM_per_page_records'}')
	echo "$result_str" | jshon -j || echo '{"status": 1,"msg": "Err"}'
	return
elif [ "${FORM_action}" = "net_record_server_visit_get_page" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result_str=$(shellgui '{"action": "net_record_server_visit_get_page", "per_page_records": '$FORM_per_page_records', "page": '$FORM_page'}')
	echo "$result_str" | jshon -j || echo '{"status": 1,"msg": "Err"}'
	return
elif [ "${FORM_action}" = "net_record_search_keyword_get_page" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	result_str=$(shellgui '{"action": "net_record_search_keyword_get_page", "per_page_records": '$FORM_per_page_records', "page": '$FORM_page'}')
	echo "$result_str" | jshon -j || echo '{"status": 1,"msg": "Err"}'
	return
elif [ "${FORM_action}" = "net_record_enable" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ "$FORM_enabled" -gt 0 ]; then
	touch /usr/shellgui/shellguilighttpd/www/apps/lan-net-record/F995-net-record.fw.enabled
	cat <<EOF
{"status": 0 ,"msg": "${_LANG_Form_Enabled}"}
EOF
	/usr/shellgui/shellguilighttpd/www/apps/lan-net-record/F995-net-record.fw stop &>/dev/null
	/usr/shellgui/shellguilighttpd/www/apps/lan-net-record/F995-net-record.fw start &>/dev/null
	else
	rm -f /usr/shellgui/shellguilighttpd/www/apps/lan-net-record/F995-net-record.fw.enabled
	cat <<EOF
{"status": 0 ,"msg": "${_LANG_Form_Disabled}"}
EOF
	/usr/shellgui/shellguilighttpd/www/apps/lan-net-record/F995-net-record.fw stop &>/dev/null
	fi
fi
}

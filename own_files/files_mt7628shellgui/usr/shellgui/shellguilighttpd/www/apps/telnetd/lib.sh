#!/bin/sh
base_dir="/usr/shellgui/shellguilighttpd/www/apps/telnetd"
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "telnetd_switch" ] &>/dev/null; then
empty='{}';config_str=$(jshon -F "$base_dir"/telnetd.json)
echo "${config_str:-${empty}}" | jshon -d "enabled" -n ${FORM_enabled} -i "enabled" -j > "$base_dir"/telnetd.json
"$base_dir"/S1301-telnetd.init restart &>/dev/null
[ ${FORM_enabled} -gt 0 ] && status_str="${_LANG_Form_Enabled}" || status_str="${_LANG_Form_Disabled}"
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Telnetd $status_str ${_LANG_Form_Success}!"}
EOF
	return
elif [ "${FORM_action}" = "use_port" ] &>/dev/null; then
empty='{}';config_str=$(jshon -F "$base_dir"/telnetd.json)
echo "${config_str:-${empty}}" | jshon -d "port" -n ${FORM_port} -i "port" -j > "$base_dir"/telnetd.json
"$base_dir"/S1301-telnetd.init restart &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Telnetd ${_LANG_Form_Port_modify_to} ${FORM_port} ${_LANG_Form_Success}!"}
EOF
	return
fi
}

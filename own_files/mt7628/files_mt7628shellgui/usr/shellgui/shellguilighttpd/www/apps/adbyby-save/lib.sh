#!/bin/sh
config_file="/usr/shellgui/shellguilighttpd/www/apps/adbyby-save/adbyby-save.json"
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "adbyby_switch" ] &>/dev/null; then
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
_Global_SW_mode=$(uci get network.wan._Global_SW_mode 2>/dev/null)
[ -n "$_Global_SW_mode" ] && if ! echo "$_Global_SW_mode" | grep -q "adbyby-save"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_success}!"}
EOF
if [ ${FORM_enabled:-0} -gt 0 ]; then
echo '{}' | jshon -n ${FORM_enabled} -i enabled -j >$config_file
uci set network.wan._Global_SW_mode="adbyby-save"
uci commit network
else
echo '{}' | jshon -n 0 -i enabled -j >$config_file
uci set network.wan._Global_SW_mode=
uci commit network
fi
/usr/shellgui/shellguilighttpd/www/apps/adbyby-save/S1580-adbyby-save.init restart &>/dev/null
/usr/shellgui/shellguilighttpd/www/apps/adbyby-save/adbyby-save.sbin fw_restart &>/dev/null
	return
fi
}

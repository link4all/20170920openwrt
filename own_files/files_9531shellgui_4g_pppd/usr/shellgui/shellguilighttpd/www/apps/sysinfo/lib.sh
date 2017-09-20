#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "hostname_edit" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
uci set system.@system[0].hostname="$FORM_hostname"
uci commit system
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Host_name} ${_LANG_Form_Setup_is_successful_will_take_effect_after_reboot}!"}
EOF
	return
elif [ "${FORM_action}" = "timezone_edit" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ ! ${FORM_web_ctl_port} -gt 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Port_out_of_range}!"}
EOF
		return
	fi
uci set system.@system[0].timezone="$FORM_zonename"
uci set system.ntp.server=
env | grep FORM_ntp_server_ | cut -d '=' -f2 | while read server; do
uci add_list system.ntp.server="${server}"
done
uci set system.ntp.enable_server=${FORM_enable_server}
uci commit system
old_port=$(grep '^server.port' /usr/shellgui/shellguilighttpd/etc/lighttpd/lighttpd.conf | grep -Eo '[0-9]*$')
if [ ${old_port} -ne ${FORM_web_ctl_port} ]; then
	sed -i "s/server.port[ ]*=.*/server.port = ${FORM_web_ctl_port}/g" /usr/shellgui/shellguilighttpd/etc/lighttpd/lighttpd.conf
fi
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Time_zone} ${_LANG_Form_Setup_is_successful_will_take_effect_after_reboot}!"}
EOF
	return
fi
}

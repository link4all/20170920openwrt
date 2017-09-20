#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "restore" ] &>/dev/null; then
env | grep "^FORM_bak_file_" | cut -d '=' -f2- > /tmp/sysupgrade.conf
/usr/shellgui/progs/main.sbin first_boot &>/dev/null
reboot &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Runing_restore_factory_setting}", "jump_url": "/?app=login", "seconds": 180000}
EOF
	return
elif [ "${FORM_action}" = "flash" ] &>/dev/null; then
env | grep "^FORM_bak_file_" | cut -d '=' -f2- > /tmp/sysupgrade.conf
/usr/shellgui/progs/main.sbin flash_firmware &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Flashing_the_firmware_please_wait}", "jump_url": "/?app=login", "seconds": 300000}
EOF
	return
fi
}

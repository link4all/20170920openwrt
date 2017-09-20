#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "wakeup" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Wake_up_order_has_been_sent},IP:$FORM_bcastIp,MAC:$FORM_mac"}
EOF
wol -i "$FORM_bcastIp" "$FORM_mac" &>/dev/null
return
fi
}

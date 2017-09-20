#!/bin/sh
main()
{
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "get_bandwidth" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
[ -n "$FORM_monitor" ] || return
date -u "+%s"
for id in $FORM_monitor; do bw-gain -i "$id" -h -m;done
return
elif [ "${FORM_action}" = "del_data" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
{"status":0,"msg":"${_LANG_Form_Data_deled}!"}
EOF
/usr/shellgui/progs/bwmond stop &>/dev/null
rm -rf /tmp/data/bwmon/*
rm -rf /usr/data/bwmon/*
shellgui '{"action":"exec_command","cmd":"/usr/shellgui/progs/bwmond","arg":"start","is_daemon":1,"timeout": 100000}' &>/dev/null
return
fi
}

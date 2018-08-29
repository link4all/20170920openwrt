#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "bw_set" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "{"$(env | grep FORM_dev_ | sed -e 's#^FORM_dev_#"#g' -e 's#=#":"#g' -e 's#$#M",#g' | tr -d '\n' | sed 's/,$//')"}" | jshon >/usr/shellgui/bw_set.conf
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modified}!"}
EOF
	return
elif [ "${FORM_action}" = "set_eth_bw" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	bw_set_str=$(jshon -F /usr/shellgui/bw_set.conf);[ -z "$bw_set_str" ] && bw_set_str='{}'
	echo "$bw_set_str" | jshon -d "$FORM_eth" -s "${FORM_bw:-100}" -i "$FORM_eth" >/usr/shellgui/bw_set.conf
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modified}!"}
EOF
	return
fi
}

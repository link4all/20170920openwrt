#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "disabled_nic" ] &>/dev/null; then
# action: disabled_nic 禁用网卡
uci set wireless.${FORM_nic}.disabled=${FORM_disabled}
uci commit wireless
if [ ${FORM_disabled} -gt 0 ]; then
_LANG_status="${_LANG_Form_is_disabled}"
else
_LANG_status="${_LANG_Form_is_enabled}"
fi
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Wireless_card}: ${FORM_nic} ${_LANG_status}!"}
EOF
	(wifi down &>/dev/null; wifi up &>/dev/null) &
	return
elif [ "${FORM_action}" = "disabled_ap" ] &>/dev/null; then
# action: disabled_ap 禁用ap
uci set wireless.${FORM_ap}.disabled=${FORM_disabled}
uci commit wireless
ssid=$(uci get wireless.${FORM_ap}.ssid)
if [ ${FORM_disabled} -gt 0 ]; then
_LANG_status="${_LANG_Form_is_disabled}"
else
_LANG_status="${_LANG_Form_is_enabled}"
fi
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ap}: ${ssid} ${_LANG_status}!"}
EOF
	(wifi down &>/dev/null; wifi up &>/dev/null) &
	return
elif [ "${FORM_action}" = "save_nic" ] &>/dev/null; then
# action: save_nic 网卡设置编辑
uci set wireless.${FORM_nic}.channel=${FORM_channel}
[ -n "$FORM_ht" ] && uci set wireless.${FORM_nic}.ht=${FORM_ht}
if [ -n "$FORM_htmode" ] && [ ! uci get wireless.${FORM_nic}.hwmode | grep -q "a" ]; then
	if [ ${FORM_channel} -gt 7 ]; then
	uci set wireless.${FORM_nic}.htmode='HT40-'
	else
	uci set wireless.${FORM_nic}.htmode='HT40+'
	fi
else
	uci set wireless.${FORM_nic}.htmode="$FORM_htmode"
fi
uci set wireless.${FORM_nic}.country='US'
if [ "${FORM_txpower}" = "max" ]; then
uci set wireless.${FORM_nic}.txpower=27
elif [ "${FORM_txpower}" = "mid" ]; then
uci set wireless.${FORM_nic}.txpower=17
elif [ "${FORM_txpower}" = "min" ]; then
uci set wireless.${FORM_nic}.txpower=7
fi
uci commit wireless
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Wireless_card}: ${FORM_nic} ${_LANG_Form_Wireless_card_setting_modified}"}
EOF
	(wifi down &>/dev/null; wifi up &>/dev/null) &
	return
elif [ "${FORM_action}" = "save_ap" ] &>/dev/null; then
# action: save_ap ap设置编辑
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "$FORM_ssid") -ge 2 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_SSID_length_must_more_then_2_char}"'"}' && return 1
		if [ "${FORM_encryption}" != "none" ]; then
			[ $(expr length "$FORM_key") -gt 8 ]
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Password_length_must_more_then_8_char}"'"}' && return 1
		fi
network=$(uci get wireless.${FORM_ap}.network)
ssid=$(uci get wireless.${FORM_ap}.ssid)
uci set wireless.${FORM_ap}.network="${FORM_network}"
uci set wireless.${FORM_ap}.ssid="${FORM_ssid}"
uci set wireless.${FORM_ap}.encryption="${FORM_encryption}"
if [ "${FORM_encryption}" = "none" ]; then
	uci set wireless.${FORM_ap}.key=
else
	uci set wireless.${FORM_ap}.key="${FORM_key}"
fi
uci set wireless.${FORM_ap}.hidden="${FORM_hidden}"
uci commit wireless
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ap}: ${ssid} ${_LANG_Form_Ap_setting_modified}"}
EOF
	if [ "$network" = "${FORM_network}" ]; then
	(wifi down &>/dev/null; wifi up &>/dev/null) &
	else
	/etc/init.d/network restart &>/dev/null &
	fi
	return
fi
}

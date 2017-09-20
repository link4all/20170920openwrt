#!/bin/sh
config_file="/usr/shellgui/shellguilighttpd/www/apps/usb-tethering-modem/usb-tethering-modem.json"
hotplug_file="/etc/hotplug.d/usb/10-usb-tethering-modem"
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "usb_tethering_switch" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
_Global_HW_mode=$(uci get network.wan._Global_HW_mode 2>/dev/null)
[ -n "$_Global_HW_mode" ] && if ! echo "$_Global_HW_mode" | grep -q "usb-tethering-modem"; then
	occupied_app=$(jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_HW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u)
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Global_mode_has_been_occupied_by} ${occupied_app}"}
EOF
	return
fi
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_success}!"}
EOF
if [ ${FORM_enabled:-0} -gt 0 ]; then
echo '{}' | jshon -n ${FORM_enabled} -i enabled -j >$config_file
/usr/shellgui/progs/main.sbin wan_dev_bak
uci set network.wan._Global_HW_mode="usb-tethering-modem"
uci set network.wan.proto="dhcp"
uci commit network
mkdir -p /etc/hotplug.d/usb/
cat <<'EOF' >$hotplug_file
#!/bin/sh
if [ "$ACTION" = "add" ]; then
	if [ -f /sys/${DEVPATH}/net/*/address ]; then
	net_dev=$(dirname /sys/${DEVPATH}/net/*/address | xargs basename)
	product_id=$(echo "$PRODUCT" | cut -d '/' -f1-2 | tr '/' ':')
	product_desc=$(lsusb -d ${product_id})
	jshon -n {} \
	-s "${net_dev}" -i net_dev \
	-s "${product_id}" -i product_id \
	-s "${product_desc}" -i product_desc -j | /usr/shellgui/progs/main.sbin usb_tethering_modem &
	fi
fi
EOF
else
echo '{}' | jshon -n 0 -i enabled -j >$config_file
rm -f $hotplug_file
_origin_ifname=$(uci get network.wan._origin_ifname)
uci set network.wan=
uci set network.wan=interface
uci set network.wan.ifname="${_origin_ifname}"
uci set network.wan.proto="dhcp"
uci commit network
fi
/usr/shellgui/shellguilighttpd/www/apps/usb-tethering-modem/S1410-usb-tethering-modem.init restart  &>/dev/null
shellgui '{"action":"exec_command","cmd":"/etc/init.d/network","arg":"restart","is_daemon":1,"timeout":50000}' &>/dev/null
	return
elif [ "${FORM_action}" = "get_status" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
ifname=$(uci get network.wan.ifname)
product_desc=$(uci get network.wan._product_desc)
	if [ -n "$ifname" ] && [ -n "$product_desc" ] && ifconfig ${ifname} &>/dev/null; then
echo '{}' | jshon -n 0 -i status -s "${ifname}" -i ifname -s "${product_desc}" -i product_desc -j
else
cat <<EOF
{"status":1}
EOF
fi
	return
fi
}

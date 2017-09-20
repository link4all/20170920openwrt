#!/bin/sh

ENABLE_FILE='/usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init.enabled'
CRON_FILE='/usr/shellgui/shellguilighttpd/www/apps/wire-ap/root.cron'
edit_ac_ip() {
sed -i '/REMOTE_ADDR/d' /usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap-conf.txt
echo "REMOTE_ADDR=\"${FORM_ac_ip}\"" >> /usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap-conf.txt
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
{"status":0,"msg":"ac ip 已变更"}
EOF
}
initialize_apctrl() {
passwd apctrl <<EOF &>/dev/null
apctrl
apctrl
EOF

printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
{"status":0,"msg":"密码已重置"}
EOF
}
disable_ap_mode() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
{"status":0,"msg":"xxx"}
EOF
rm -f ${ENABLE_FILE} ${CRON_FILE}
encrontab
/etc/init.d/cron restart &>/dev/null
}

enable_ap_mode() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
cat <<EOF
{"status":0,"msg":"xxx"}
EOF
touch ${ENABLE_FILE} ${CRON_FILE}
encrontab
/etc/init.d/cron restart &>/dev/null
}
encrontab() {
cat <<EOF > /usr/shellgui/shellguilighttpd/www/apps/wire-ap/root.cron
* * * * * /usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init update
0 */12 * * * /usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init
EOF
}
main() {
case $FORM_action in
enable_ap_mode)
enable_ap_mode
;;
disable_ap_mode)
disable_ap_mode
;;
initialize_apctrl)
initialize_apctrl
;;
edit_ac_ip)
edit_ac_ip
;;
esac
}
#!/bin/sh
kill -9 $(cat /tmp/shadowvpn.firewall.running) &>/dev/null
rm -f /tmp/shadowvpn.firewall.running
/usr/shellgui/shellguilighttpd/www/apps/shadowvpn/shadowvpn.sbin client_start
# /usr/shellgui/shellguilighttpd/www/apps/shadowvpn/shadowvpn.sbin start_fw


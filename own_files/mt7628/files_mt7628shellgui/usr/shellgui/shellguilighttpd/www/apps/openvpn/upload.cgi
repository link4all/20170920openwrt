#!/usr/bin/haserl --upload-limit=24 --upload-dir=/tmp/
<% 
rm -f /tmp/client.7z
mv $HASERL_file_path /tmp/client.7z
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
rm -rf /tmp/client_tmp
mkdir -p /tmp/client_tmp
7za x /tmp/client.7z -o/tmp/client_tmp &>/dev/null
rm -f /tmp/client.7z
old_conf_name=$(ls /tmp/client_tmp/*.conf | sed -n 1p)
old_conf_name=$(basename "${old_conf_name}" | cut -d '.' -f1)
[ -n "${old_conf_name}" ] || exit

rm -rf /etc/openvpn/client.* /etc/openvpn/client_* /etc/openvpn/block_non_openvpn

mv -f /tmp/client_tmp/${old_conf_name}.conf /etc/openvpn/client.conf
mv -f /tmp/client_tmp/${old_conf_name}.key /etc/openvpn/client.key
mv -f /tmp/client_tmp/${old_conf_name}.crt /etc/openvpn/client.crt
mv -f /tmp/client_tmp/ta.key /etc/openvpn/client_ta.key
mv -f /tmp/client_tmp/ca.crt /etc/openvpn/client_ca.crt
mv -f /tmp/client_tmp/block_non_openvpn /etc/openvpn/block_non_openvpn

rm -rf /tmp/client_tmp/
. /usr/shellgui/shellguilighttpd/www/apps/openvpn/lib.sh
correct_client_conf "/etc/openvpn"

printf "Location: /?app=openvpn&active=cli\r\n\r\n"
exit
%>


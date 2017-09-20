#!/usr/bin/haserl --upload-limit=2048 --upload-dir=/tmp/
<%
kill -9 $(cat /tmp/geoip_upload.pid)
echo $$ >/tmp/geoip_upload.pid
rm -rf /tmp/geoip.7z /tmp/geoip_upload
mkdir -p /tmp/geoip_upload;
mv $HASERL_file_path /tmp/geoip.7z
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null; then
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
7za x /tmp/geoip.7z -o/tmp/geoip_upload &>/dev/null
endianness=$(shellgui '{"action":"get_endianness"}' | jshon -e "endianness" -u)
dir=$(find /tmp/geoip_upload -type d | grep -m 1 -E "\/${endianness}$")
[ -n "${dir}" ] && mkdir -p /usr/share/xt_geoip/ && cp -R ${dir} /usr/share/xt_geoip/ &>/dev/null
cat <<EOF > /usr/share/xt_geoip/last_version
{"ver":1,"timestamp":$(date +%s)}
EOF
/etc/init.d/firewall stop &>/dev/null
rmmod xt_geoip
for i in $(seq 1 5); do
lsmod | grep -q 'xt_geoip' && break || insmod xt_geoip
sleep 1
done
shellgui  '{"action":"exec_command","cmd":"/etc/init.d/firewall","arg":"start","is_daemon":1,"timeout":50000}' &>/dev/null
%>{"status":0,"seconds":"2000","msg":"上传成功","jump_url":"/?app=firewall-extra"}<% 
else
%>{"status":1,"seconds":"2000","msg":"Please Login","jump_url":"/?app=login"}<%
fi %>

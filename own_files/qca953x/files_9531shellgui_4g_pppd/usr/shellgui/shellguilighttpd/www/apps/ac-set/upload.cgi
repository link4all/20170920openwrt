#!/usr/bin/haserl --upload-limit=16192 --upload-dir=/tmp/
<%
if [ "$HTTP_USER_AGENT" = "$(cat /tmp/ap_fw.md5)" ]; then
	cat /tmp/firmware-ap.img | /usr/shellgui/progs/main.sbin http_download firmware-ap.img
	exit
fi
mv -f $HASERL_file_path /tmp/firmware-ap.img
md5_str=$(md5sum /tmp/firmware-ap.img | cut -d ' ' -f1)
# printf "Content-Type: text/json\r\n\r\n"
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if [ -n "$POST_file_name" ] && [ -n "${md5_str}" ]; then
size=$(ls -l /tmp/firmware-ap.img | awk '{print $5}')
size_str=$(shellgui '{"action": "bit_conver", "bit": '"$size"'}' | jshon -e "result" -u)
cat <<EOF
{"status": "0","msg":"上传成功","file": "$POST_file_name", "md5": "${md5_str}", "size": "${size_str}"}
EOF
else
cat <<EOF
{"status": 1, "msg": "upload fails"}
EOF
fi
exit
%>

#!/usr/bin/haserl --upload-limit=8192 --upload-dir=/tmp/
<% 
rm -f /tmp/firmware-ap.img
mv $HASERL_file_path /tmp/firmware-ap.img

md5_str=$(md5sum /tmp/firmware-ap.img | cut -d ' ' -f1)
printf "Content-Type: text/json\r\n\r\n"
if [ -n "$POST_file_name" ] && [ -n "${md5_str}" ]; then
size=$(ls -l /tmp/firmware-ap.img | awk '{print $5}')
size_str=$(shellgui '{"action": "bit_conver", "bit": '"$size"'}' | jshon -e "result" -u)
cat <<EOF
{"file": "$POST_file_name", "md5": "${md5_str}", "size": "${size_str}"}
EOF
else
cat <<EOF
{"status": 1, "msg": "upload fails"}
EOF
fi
exit
%>


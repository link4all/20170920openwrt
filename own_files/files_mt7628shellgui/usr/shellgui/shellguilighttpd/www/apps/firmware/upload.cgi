#!/usr/bin/haserl --upload-limit=16384 --upload-dir=/tmp/
<% 
rm -f /tmp/firmware.img
mv $HASERL_file_path /tmp/firmware.img
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
printf "Location: /?app=firmware&action=preflash&file=$POST_file_name\r\n\r\n"
exit
%>


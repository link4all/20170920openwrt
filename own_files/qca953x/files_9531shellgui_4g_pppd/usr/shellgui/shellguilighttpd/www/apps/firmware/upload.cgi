#!/usr/bin/haserl --upload-limit=1638400 --upload-dir=/tmp/
<% 
rm -f /tmp/firmware.img
mv -f $HASERL_file_path /tmp/firmware.img
eval $QUERY_STRING
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' firmware $lang)
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null; then
	. /lib/functions.sh;
	include /lib/upgrade;
	platform_check_image /tmp/firmware.img &>/dev/null
	if [ $? -eq 0 ]; then
%>{"status":0,"seconds":"2000","msg":"<%= ${_LANG_Form_Firmware_is_flashable_whatever_flash} %>","jump_url":"/?app=firmware&action=preflash&file=<%= $POST_file_name %>"}<% 
	else
%>{"status":1,"seconds":"2000","msg":"<%= ${_LANG_Form_Firmware_is_unflashable} %>","jump_url":"/?app=firmware"}<% 
	fi
else
%>{"status":1,"seconds":"2000","msg":"Please Login","jump_url":"/?app=login"}<% 
fi
exit
%>

#!/usr/bin/haserl --upload-limit=16384 --upload-dir=/tmp/
<% 
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
if [ $? -ne 0 ]; then
%>{"status":1,"seconds":"2000","msg":"请登录","jump_url":"/?app=login"}<% 
else
mv $HASERL_file_path /tmp/$FORM_file_name
mv /tmp/$FORM_file_name $FORM_path
%>{"status":0,"seconds":"2000","msg":"上传成功","jump_url":"/?app=filebrowser&old_path=<%= $FORM_path %>"}<% 
fi
exit
%>

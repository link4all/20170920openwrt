#!/usr/bin/haserl --upload-limit=128 --upload-dir=/tmp/
<% 
env >/tmp/1
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null; then
if ! mv $HASERL_file_path /usr/shellgui/shellguilighttpd/www/apps/port-remote/certs/${FORM_file_name:-new-cert.pem}; then
%>{"status": "1","seconds":"2000","msg":"上传失败","jump_url":"/?app=port-remote"}<%
exit
rm -f $HASERL_file_path
fi
%>{"status": "0","seconds":"2000","msg":"上传成功","jump_url":"/?app=port-remote"}<% 
else
%>{"status": "1","seconds":"2000","msg":"Please Login","jump_url":"/?app=login"}<%
rm -f $HASERL_file_path
fi
%>

#!/usr/bin/haserl --upload-limit=24 --upload-dir=/tmp/
<% 
rm -f /tmp/client.json
mv $HASERL_file_path /tmp/client.json
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null; then
config_str=$(cat /tmp/client.json)
server=$(echo "$config_str" | jshon -e "server" -u)
mtu=$(echo "$config_str" | jshon -e "mtu" -u)
port=$(echo "$config_str" | jshon -e "port" -u)
server_iner_ip=$(echo "$config_str" | jshon -e "server_iner_ip" -u)
net=$(echo "$config_str" | jshon -e "net" -u)
password=$(echo "$config_str" | jshon -e "password" -u)
uci set shadowvpn.@shadowvpn[0].enable='0'
uci set shadowvpn.@shadowvpn[0].server="${server}"
uci set shadowvpn.@shadowvpn[0].mode='client'
uci set shadowvpn.@shadowvpn[0].port="${port}"
uci set shadowvpn.@shadowvpn[0].password="${password}"
uci set shadowvpn.@shadowvpn[0].concurrency="1"
uci set shadowvpn.@shadowvpn[0].net="${net}"
uci set shadowvpn.@shadowvpn[0].mtu="${mtu}"
uci set shadowvpn.@shadowvpn[0].intf='ss0'
uci set shadowvpn.@shadowvpn[0].server_iner_ip="${server_iner_ip}"
uci commit shadowvpn
%>{"status": "0","seconds":"2000","msg":"上传成功","jump_url":"/?app=shadowvpn&active=cli"}<% 
else
%>{"status": "1","seconds":"2000","msg":"Please Login","jump_url":"/?app=login"}<%
fi %>

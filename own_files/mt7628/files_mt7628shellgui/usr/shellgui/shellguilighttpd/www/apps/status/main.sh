#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
	if [ "${GET_action}" = "bw_status" ] &>/dev/null; then
	id=$(echo ${COOKIE_session} | grep -Eo '.....$')
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "ifces_bw_status", "session": "'"$id"'"}'
    return
	elif [ "${GET_action}" = "hw_status" ] &>/dev/null; then
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
memswap_str=$(shellgui '{"action": "get_mem_status", "readable": 1}' | jshon -j)
        cat <<EOF
{"uptime":$(shellgui '{"action": "get_uptime"}' | jshon -e "formatted" -j),"cpu":$(shellgui '{"action": "get_cpu_usage"}' | jshon -e "detail" -j),"swap":$(echo "$memswap_str" | jshon -e "swap" -j),"mem":$(echo "$memswap_str" | jshon -e "mem" -j)}
EOF
    return
	fi
	time_now=$(date +%s)
	ls /tmp/bw_last-*.json -l  -e | while read line; do
	time_file=$(date -D "%b %d %H:%M:%S %Y" -d "$(echo "${line}" | awk '{print $7" "$8" "$9" "$10}')" +%s)

	[ $(expr ${time_now} - ${time_file}) -gt 300 ]  && file=$(echo "${line}" | awk '{print $NF}') && rm -f ${file}
	done
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<%in /usr/shellgui/shellguilighttpd/www/apps/status/html_lib.sh %>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "status"}' %>
</div>
<div id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type// /-} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name// /-}")" %>"><span class="glyphicon glyphicon-link"></span></a></div>
</div>
    <div class="container">
<% if [ "$FORM_action" = "edit_network_status" ]; then
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "编辑带宽"}}'
edit_network_status
else
index
fi
%>
    </div>
  </div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end '{"js":["/apps/status/status.js"]}'
%>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
if [ -z "$FORM_action" ]; then
%>
Ha.mask.show();
askStatus();
setInterval(function(){
    askStatus();
},5000);
<% fi %>
</script>
</body>
</html>
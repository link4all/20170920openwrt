#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
dev_scan() {
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app=wifi-client"}, "3": {"title": "'"${_LANG_Form_Scan}"'"}}'
%>
    <div id="stas_container" data-dev="<%= ${FORM_dev} %>">
      <div class="content">
        <table class="table table-hover">
	      <thead>
	        <tr>
	          <td colspan="2" style="text-align: right;">
	            <a href="/?app=wifi-client"><button class="btn btn-info" id="goback"><%= ${_LANG_Form_Back} %></button></a>
	            <button class="btn btn-default" id="refresh"><%= ${_LANG_Form_Flash} %></button>
	          </td>
	        </tr>
	      </thead>
          <tbody id="sta_container"></tbody>
        </table>
      </div>
    </div>
<%
}
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>

<div id="main">

	<div class="container">

<%
if [ "$FORM_action" = "dev_scan" ]; then
  dev_scan
else

/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
%>
    <div id="nic_container"></div>
<% 
fi 
%>
	</div> 
</div>

<% /usr/shellgui/progs/main.sbin h_f%>

<% /usr/shellgui/progs/main.sbin h_end
%>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<%
if [ -z "$FORM_action" ]; then
%>
<script src="/apps/wifi-client/wifi_client.js"></script>
<%
elif [ "$FORM_action" = 'dev_scan' ]; then
%>
<script src="/apps/wifi-client/nic.js"></script>
<%
fi
%>
</body>
</html>
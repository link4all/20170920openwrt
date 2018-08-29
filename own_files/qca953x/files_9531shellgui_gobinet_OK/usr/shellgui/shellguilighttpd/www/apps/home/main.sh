#!/usr/bin/haserl
<%
if shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null; then
	if [ "$FORM_app" != "home" ]; then
		printf "Location: /?app=wifi\r\n\r\n";exit
	fi
else
	printf "Location: /?app=login\r\n\r\n";exit
fi
if [ ! -f /tmp/home.json ]; then
/usr/shellgui/progs/main.sbin h_ji
fi
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
if [ -f /tmp/$COOKIE_session.temp_home_nav ]; then
cat /tmp/$COOKIE_session.temp_home_nav
else
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' | tee /tmp/$COOKIE_session.temp_home_nav
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_' ${FORM_app} $COOKIE_lang) %>
</div>
  <div id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type// /-} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name// /-}")" %>"><span class="icon-link"></span></a></div>
</div>
<%
home_json=$(jshon -e "i18n" < /tmp/home.json)
user=$(echo $COOKIE_session | cut -d '-' -f1)
id=$(shellgui '{"action":"get_user_detail","username":"'"${user}"'"}' | jshon -e "user_detail" -e "uid" -u)
show_type() {
%>
    <div class="container">
      <div class="header">
        <h1 id="<%= ${type} %>"><%= ${type} %></h1>
      </div>
      <div class="content row row">
<% for app in $(echo "$home_json" | jshon -S -e "${COOKIE_lang}" -e "${type}" -k); do
	echo "$home_json" | jshon -e "${COOKIE_lang}" -e "${type}" -e "${app}" -e "uid" -a -u | grep -q "^${id}$" || continue
		eval $(echo "$home_json" | jshon -e "${COOKIE_lang}" -e "${type}" -e "${app}" -d "uid" | sed -e '1d;$d' -e 's/\,$//g' -e 's#^[ ]*\"##g' -e 's#\"\:[ ]*#=#g')
		[ $hidden -gt 0 ] && continue %>
        <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6 app">
          <!-- <a href="/?app=<%= ${app_name} %>"><img class="app-img" src="/apps/<%= ${app_name} %>/icon.png" alt="<%= ${desc} %>"> -->
		  <a href="/?app=<%= ${app_name} %>">
		  <% xsvg_height=64 xsvg_height=64 xsvg_id="${app_name//-/_}" haserl /usr/shellgui/shellguilighttpd/www/apps/${app_name}/icon.xsvg %>
            <h2 class="app-title"><%= ${app} %></h2>
          </a>
        </div>
	<% done %>
    </div>
  </div>
<%
}
if [ -f /tmp/$COOKIE_session.temp_home_app_list ]; then
cat /tmp/$COOKIE_session.temp_home_app_list
else
OLD_IFS="$IFS"; IFS=$'\x0A';
for type in $(echo "$home_json" | jshon -S -e "${COOKIE_lang}" -k); do
result=$(show_type)
echo "$result"
done | tee /tmp/$COOKIE_session.temp_home_app_list;IFS="$OLD_IFS"
fi
%>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/home/svg_animate.js"></script>
</body>
</html>

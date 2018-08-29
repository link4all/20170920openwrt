#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<%in /usr/shellgui/shellguilighttpd/www/apps/mwan3/html_lib.sh %>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<% mwan3_str=$(uci show -X mwan3)
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
type=;ifname=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans
${ifce}"
done
if [ "$FORM_action" = "edit_wan" ]; then
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "'"${_LANG_Form_Edit_Interfaces}"'"}}'
edit_wan
elif [ "$FORM_action" = "edit_member" ]; then
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "'"${_LANG_Form_Edit_Members}"'"}}'
edit_member
elif [ "$FORM_action" = "edit_policy" ]; then
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "'"${_LANG_Form_Edit_Policies}"'"}}'
edit_policy
elif [ "$FORM_action" = "edit_rule" ]; then
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "'"${_LANG_Form_Edit_Rules}"'"}}'
edit_rule
else
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
index
fi
%>
	</div> 
</div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">title</h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text">text</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/mwan3/mwan3.js"></script>
</body>
</html>

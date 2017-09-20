#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
  <div class="container">
<%in /usr/shellgui/shellguilighttpd/www/apps/ac-set/html_lib.sh %>
<%
if [ "$FORM_action" = "aplist_cp" ]; then
  aplist_cp
else
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}'
html_main
fi %>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end
if [ "$FORM_action" = "aplist_cp" ]; then
%>
<script>
var timestamp_diff = Math.round(+new Date()/1000) - <%= $(date +%s) %>;
</script>
<script src="/apps/home/common/js/jquery.form.js"></script>
<script src="/apps/home/common/js/Chart.js"></script>
<script src="/apps/ac-set/ac_set.js"></script>
<% fi %>
<script>
$('#set_ac').submit(function(){
	var post_data = 'app=ac-set&action=set_ac&'+$(this).serialize();
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
	},'json');
	return false;
});
  Ha.setFooterPosition()
</script>
</body>
</html>

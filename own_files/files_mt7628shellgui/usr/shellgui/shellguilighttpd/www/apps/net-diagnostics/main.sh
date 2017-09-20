#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
    if [ "${GET_action}" = "ping" ] &>/dev/null; then
	# action: ping 运行ping 测试
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		ping -w 2 -c ${FORM_times} ${FORM_host} 2>&1
        return
	fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
  <div class="container">
    <% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
    <div class="row">
      <div class="app app-item col-lg-12">
        <h2 class="app-sub-title"><%= ${_LANG_Form_Ping_test} %></h2>
        <div class="row">
          <form class="form-horizontal col-md-6" id="net-diag-form">
            <div class="form-group text-left">
              <label for="host" class="col-sm-2 control-label"><%= ${_LANG_Form_Host} %></label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="host" name="host" required placeholder="www.google.com">
              </div>
            </div>
            <div class="form-group text-left">
              <label for="times" class="col-sm-2 control-label"><%= ${_LANG_Form_Count} %></label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="times" name="times" required placeholder="2">
              </div>
            </div>
            <div class="form-group text-left">
              <div class="col-sm-offset-2 col-sm-10 text-left">
                <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Go} %></button>
              </div>
            </div>
          </form>
          <div class="col-md-12">
            <div class="row text-left">
              <pre class="test-result col-md-6" id="test-result">
Result/* <%= ${_LANG_Form_May_need_to_wait_long_time} %> */</pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script type="text/javascript">
  (function(){
    $('form').submit(function(){
      $('#test-result').html('Loading...');
      var url = '/?app=net-diagnostics&action=ping&' + $(this).serialize();
      var formId = $(this).prop('id');
      Ha.ajax(url,'html','','get',formId,function(data){
        $('#test-result').html(data);
        Ha.setFooterPosition();
      },1);
      return false;
    });
  })();
</script>
</body>
</html>
#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>

    	<div class="row">
    		<div class="col-sm-6">
				<form class="form-horizontal">
				  <div class="form-group">
				    <label for="title" class="col-sm-2 control-label">标题</label>
				    <div class="col-sm-10">
				      <input type="text" class="form-control" id="title" placeholder="Title">
				    </div>
				  </div>

				  <div class="form-group">
				    <label for="account" class="col-sm-2 control-label">账号</label>
				    <div class="col-sm-10">
				      <input type="text" class="form-control" id="account" placeholder="Account">
				    </div>
				  </div>

				  <div class="form-group">
				    <label for="password" class="col-sm-2 control-label">密码</label>
				    <div class="col-sm-10">
				      <input type="password" class="form-control" id="password" placeholder="password">
				    </div>
				  </div>

				  <div class="form-group">
				    <label for="mtu" class="col-sm-2 control-label">MTU</label>
				    <div class="col-sm-10">
				      <input type="text" class="form-control" id="mtu" placeholder="MTU">
				    </div>
				  </div>
				  

				  <div class="form-group">
				    <div class="col-sm-offset-2 col-sm-10">
				      <button type="submit" class="btn btn-default">应用</button>
				    </div>
				  </div>
				</form>
    		</div>
    	</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
</body>
</html>
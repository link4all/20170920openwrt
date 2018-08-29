#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
# '{"title": "路由器用户管理界面", "js":["\/apps\/home\/common\/js\/lan.js"]}'
%>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>

<div id="main">

	<div class="container">

<%
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
%>

    	<div class="content">

		  <div class="app row app-item">
			<h2 class="app-sub-title col-sm-12">初始化ap管理密码</h2>
			<div class="col-sm-offset-2 col-sm-10 text-left">
			  <p>初始化ap管理密码:</p>
			  <button type="submit" id="initialize_apctrl" class="btn btn-default">初始化ap管理密码</button>
			</div>
		  </div>

<hr>
    	<div class="content">

		  <div class="app row app-item">
			<h2 class="app-sub-title col-sm-12">AC服务器</h2>
			<div class="col-sm-offset-2 col-sm-10 text-left">

<div class="row">
      <div class="col-md-2">
          <label for="" class="">AC IP地址:</label>
      </div>
      <div class="col-md-10">

        <form class="form-inline" name="edit_ac_ip" id="edit_ac_ip">
            <div class="form-group">
			<% . /usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap-conf.txt %>
              <input class="form-control" name="ac_ip" placeholder="请输入AC主机IP" value="<%= ${REMOTE_ADDR} %>">
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-default btn-block">应用</button>
            </div>
        </form>
      </div>
</div>



			</div>
		  </div>

<hr>
		  <div class="app row app-item">
			<h2 class="app-sub-title col-sm-12">AP功能启用</h2>
			<div class="col-sm-offset-2 col-sm-10 text-left">
			  <p>AP功能启用:</p>

			  <div class="row">
				<div class="col-sm-1">
				  <label for="" class="">状态</label>
				</div>
				<div class="col-sm-11">
				  <div class="switch-ctrl head-switch" id="switch_ctrl_radio0">
					<input type="checkbox" name="nic-switch" id="switch_apmode" value="" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init.enabled ] && printf "checked" %>>
					<label for="switch_apmode"><span></span></label>
				  </div>
				</div>
			  </div>


			</div>
		  </div>

    	</div>
	</div> 
</div>

<% /usr/shellgui/progs/main.sbin h_f%>

<% /usr/shellgui/progs/main.sbin h_end
%>

<script>
$('#edit_ac_ip').submit(function(e){
  e.preventDefault();
  var data = "app=wire-ap&action=edit_ac_ip&" + $(this).serialize();
  $.post('/',data,Ha.showNotify,'json');
});
$('#initialize_apctrl').click(function(){
  var r=confirm("Press a button")
  if (r==true) {
	$.post('/','app=wire-ap&action=initialize_apctrl',Ha.showNotify,'json');
	}
});
$('#switch_apmode').click(function(){
	var status = $(this).prop('checked');
	if(status){
		$.post('/','app=wire-ap&action=enable_ap_mode',Ha.showNotify,'json');
	}else{
		$.post('/','app=wire-ap&action=disable_ap_mode',Ha.showNotify,'json');
	}
});
</script>

</body>
</html>
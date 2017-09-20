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
<div class="app row app-item">
    <h2 class="app-sub-title col-sm-12"><%= ${_LANG_App_name} %></h2>
    <div class="col-sm-offset-2 col-sm-10 text-left">
        <p><%= ${_LANG_Form_Enable_Security_Adbyby} %></p>
        <div class="row">
            <div class="col-xs-3">
                <label for="" class=""><%= ${_LANG_Form_Status} %>:</label>
            </div>
            <div class="col-xs-9">
                <div class="switch-ctrl head-switch" id="switch_adbyby_radio0" data-toggle="modal" data-target="#confirmModal">
                    <input type="checkbox" id="switch_adbyby" <% [ $(jshon -F /usr/shellgui/shellguilighttpd/www/apps/adbyby-save/adbyby-save.json -e "enabled") -gt 0 ] && printf checked%>>
                    <label for="switch_adbyby"><span></span></label>
                </div>
            </div>
        </div>
    </div>
</div>
    		</div>
    	</div>
	</div> 
</div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><%= ${_LANG_Form_Status} %></h4>
      </div>
      <div class="modal-body">
        <p id="confirm-text" class="text-center text-danger"></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_switch"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
</body>
<script>
  var UI = {};
  UI.switchOn = '<%= ${_LANG_Form_Do_you_want_to_enable} ${_LANG_App_name} %>?';
  UI.switchOff = '<%= ${_LANG_Form_Do_you_want_to_disable} ${_LANG_App_name} %>?';
  $('#switch_adbyby').click(function(){
    var status = $('#switch_adbyby').prop('checked');
    if(status){
      $('#confirm-text').html(UI.switchOn);
    }else{
      $('#confirm-text').html(UI.switchOff);
    }
    return false;
  });
	$('#confirm_switch').click(function(){
		var status = $('#switch_adbyby').prop('checked');
		if(status){
      $.post('/','app=adbyby-save&action=adbyby_switch&enabled=0',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_adbyby').prop('checked',false);
      },'json');
		}else{
      $.post('/','app=adbyby-save&action=adbyby_switch&enabled=1',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_adbyby').prop('checked',true);
      },'json');
		}
	});
</script>
</html>
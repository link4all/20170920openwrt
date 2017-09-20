#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
    	<div class="row">
    		<div class="col-sm-6">
<div class="app row app-item">
    <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_USB_Tethering_Modem_Setting} %></h2>
    <div class="col-sm-offset-2 col-sm-10 text-left">
        <p><%= ${_LANG_Form_Enable_USB_Tethering_Modem} %></p>
        <div class="row">
            <div class="col-xs-3">
                <label for="" class=""><%= ${_LANG_Form_Status} %>:</label>
            </div>
            <div class="col-xs-9">
                <div class="switch-ctrl head-switch" id="switch_usb_tethering_radio0" data-toggle="modal" data-target="#confirmModal">
                    <input type="checkbox" id="switch_usb_tethering" <% [ $(jshon -F /usr/shellgui/shellguilighttpd/www/apps/usb-tethering-modem/usb-tethering-modem.json -e "enabled") -gt 0 ] && printf checked%>>
                    <label for="switch_usb_tethering"><span></span></label>
                </div>
            </div>
            <p class="help-block col-xs-12"><%= ${_LANG_Form_After_Enabled_Wan_Port_will_out_of_action_Unless_Disabled} %></p>
        </div>
        <div id="status_container" class="hidden">
          <div class="row">
              <label for="" class="col-xs-3"><%= ${_LANG_Form_Interface_name} %>:</label>
              <div class="col-xs-9" id="ifname_conntainer">usb0</div>
          </div>
          <div class="row">
              <label for="" class="col-xs-3"><%= ${_LANG_Form_Product_Desc} %>:</label>
              <div class="col-xs-9" id="product_desc_conntainer">Google Inc.</div>
          </div>
        </div>
    </div>
</div>
<div class="app row app-item">
    <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Smart_Phone_settings_Tip} %></h2>
    <div class="col-sm-offset-2 col-sm-10 text-left">
        <p><%= ${_LANG_Form_IOS_settings} %></p>
        <div class="row">
<ul>
<li><%= ${_LANG_Form_IOS_Step1} %></li>
<li><%= ${_LANG_Form_IOS_Step2} %></li>
<li><% echo "${_LANG_Form_IOS_Step3}" | sed 's#\\##' %></li>
<li><%= ${_LANG_Form_IOS_Step4} %></li>
<li><% echo "${_LANG_Form_IOS_Step5}"  | sed 's#\\##' %></li>
<li><%= ${_LANG_Form_IOS_Step6} %></li>
</ul>
        </div>
        <p><%= ${_LANG_Form_Android_settings} %></p>
        <div class="row">
<ul>
<li><%= ${_LANG_Form_Android_Step1} %></li>
<li><% echo "${_LANG_Form_Android_Step2}" | sed 's#\\##' %></li>
</ul>
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
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.switchOn = '<%= ${_LANG_Form_Do_you_want_to_enable} ${_LANG_App_name}%>?';
UI.switchOff = '<%= ${_LANG_Form_Do_you_want_to_disable} ${_LANG_App_name}%>?';
</script>
<% /usr/shellgui/progs/main.sbin h_end %>
</body>
<script>
  $('#switch_usb_tethering').click(function(){
    var status = $('#switch_usb_tethering').prop('checked');
    if(status){
      $('#confirm-text').html(UI.switchOn);
    }else{
      $('#confirm-text').html(UI.switchOff);
    }
    return false;
  });
	$('#confirm_switch').click(function(){
		var status = $('#switch_usb_tethering').prop('checked');
		if(status){
      $.post('/','app=usb-tethering-modem&action=usb_tethering_switch&enabled=0',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_usb_tethering').prop('checked',false);
      },'json');
		}else{
      $.post('/','app=usb-tethering-modem&action=usb_tethering_switch&enabled=1',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_usb_tethering').prop('checked',true);
      },'json');
		}
	});
	function checkStatus(){
    $.post('/','app=usb-tethering-modem&action=get_status',function(data){
      if(data.status){
        $('#status_container').addClass('hidden');
      }else{
        $('#status_container').removeClass('hidden');
        $('#ifname_conntainer').html(data.ifname);
        $('#product_desc_conntainer').html(data.product_desc);
      }
      setTimeout(checkStatus,3000);
    },'json');
  }
  checkStatus();
</script>
</html>

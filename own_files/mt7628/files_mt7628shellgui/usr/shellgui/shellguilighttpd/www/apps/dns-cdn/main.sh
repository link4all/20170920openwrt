#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
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
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
get_dns_cdn() {
local IFS=','
for i in $(uci get chinadns.@chinadns[0].server);do
echo ${i} | grep -v 127.0.0.1 ;done | tr '\n' ',' | sed 's/,$//'
} %>
         <div class="content">
            <div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_DNS_CDN_Accelerator} %></h2>
				<p class="col-sm-12 text-left">
					<span><%= ${_LANG_Form_Status} %>: </span><span id="server_status"><% pidof chinadns &>/dev/null && printf "${_LANG_Form_Runed}" || printf "${_LANG_Form_Not_Runed}" %></span>
				</p>
                <div class="col-sm-offset-2 col-sm-6 text-left">
                    	<div class="form-group">
                    		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enable} ${_LANG_Form_DNS_CDN_Accelerator} %></label>
                    		<div class="col-sm-8">
							  <div class="switch-ctrl head-switch" id="switch_dnscdn_radio0" data-toggle="modal" data-target="#confirmModal">
								  <input type="checkbox" name="nic-switch" id="switch_dnscdn" value="" <% grep -q 'server=/#/127.0.0.1' /usr/shellgui/shellguilighttpd/www/apps/dns-cdn/all.dnsmasqd && printf 'checked' %>>
								  <label for="switch_dnscdn"><span></span></label>
							  </div>
                    		</div>
                    	</div>
                </div>
                <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_DNS_CDN_Setting} %></h2>
                <div class="col-sm-offset-2 col-sm-6 text-left">
                    <form class="form-horizontal text-left" id="set_dnscdn">
					<fieldset id="set_dnscdn_form" <% grep -q 'server=/#/127.0.0.1' /usr/shellgui/shellguilighttpd/www/apps/dns-cdn/all.dnsmasqd || printf 'disabled' %>>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_DNS_Server_CDN_Supported} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="chinadns_ips" name="chinadns_ips" value="<% get_dns_cdn %>" placeholder="114.114.114.114,223.5.5.5">
								<span class="help-block hidden"><%= ${_LANG_Form_Allow_multi_servers__Comma_separated} %></span>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Secondary_DNS_Server} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="dns_forwader_ip" name="dns_forwader_ip" value="<% uci get dns-forwarder.@dns-forwarder[0].dns_servers %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Secondary_DNS_Server_use_TCP} %></label>
							<div class="col-sm-8">
							  <div class="switch-ctrl head-switch <% grep -q 'server=/#/127.0.0.1' /usr/shellgui/shellguilighttpd/www/apps/dns-cdn/all.dnsmasqd || printf 'disabled' %>">
								  <input type="checkbox" name="enable_dnsforwader" id="switch_assist_dns" value="1" <% [ $(uci get dns-forwarder.@dns-forwarder[0].enable) -gt 0 ] && printf 'checked' %>>
								  <label for="switch_assist_dns"><span></span></label>
							  </div>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Resolve_by_socks5__when_socks5_enabled} %></label>
							<div class="col-sm-8">
							  <div class="switch-ctrl head-switch <% grep -q 'server=/#/127.0.0.1' /usr/shellgui/shellguilighttpd/www/apps/dns-cdn/all.dnsmasqd || printf 'disabled' %>">
								  <input type="checkbox" name="enable_socks5tproxy" id="switch_socks5tproxy" value="1" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/dns-cdn/dnsforward.socks5tproxy ] && printf 'checked' %>>
								  <label for="switch_socks5tproxy"><span></span></label>
							  </div>
							</div>
						</div>
						<div class="form-group">
							<div class="col-sm-offset-4 col-sm-8">
								<button type="submit" id="submit_btn" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
							</div>
						</div>
					</fieldset>
					</form>
                </div>
            </div>
        </div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><%= ${_LANG_Form_DNS_CDN_Accelerator} ${_LANG_Form_Status} %></h4>
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
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
  var UI = {};
  UI.switchOn = '<%= ${_LANG_Form_Enable} ${_LANG_Form_DNS_CDN_Accelerator} %>?';
  UI.switchOff = '<%= ${_LANG_Form_Disnable} ${_LANG_Form_DNS_CDN_Accelerator} %>?';
  $('#switch_dnscdn').click(function() {
      var status = $('#switch_dnscdn').prop('checked');
      if (status) {
          $('#confirm-text').html(UI.switchOn);
          validateFuc($('#dns_forwader_ip'),va.validateIP($('#dns_forwader_ip').val()));
          validateFuc($('#chinadns_ips'),validateIPS($('#chinadns_ips').val()));
      } else {
          disableBtn();
          $('#confirm-text').html(UI.switchOff);
          $('.help-block').addClass('hidden');
          $('.has-error').removeClass('has-error');
      }
      return false;
  });
  $('#confirm_switch').click(function() {
      var status = $('#switch_dnscdn').prop('checked');
      if (status) {
		  $("#set_dnscdn_form").prop('disabled',true)
          $.post('/', 'app=dns-cdn&action=disable_dns_cdn', function(data) {
      	  	  $('#switch_assist_dns,#switch_socks5tproxy').parent().addClass('disabled');
              $('#confirmModal').modal('hide');
              Ha.showNotify(data);
              $('#switch_dnscdn').prop('checked', false);
          }, 'json');
      } else {
		  $("#set_dnscdn_form").prop('disabled',false)
          $.post('/', 'app=dns-cdn&action=enable_dns_cdn', function(data) {
      	  	  $('#switch_assist_dns,#switch_socks5tproxy').parent().removeClass('disabled');
              $('#confirmModal').modal('hide');
              Ha.showNotify(data);
              $('#switch_dnscdn').prop('checked', true);
          }, 'json');
      }
  });
    $('#set_dnscdn').submit(function(e){
      e.preventDefault();
      var error = disableBtn();
      if(error){
        validateFuc($('#dns_forwader_ip'),va.validateIP($('#dns_forwader_ip').val()));
        validateFuc($('#chinadns_ips'),validateIPS($('#chinadns_ips').val()));
        return;
      }else{
        var data = "app=dns-cdn&action=set_dnscdn&"+$(this).serialize();
        Ha.disableForm('set_dnscdn');
        $('#switch_assist_dns,#switch_socks5tproxy').parent().addClass('disabled');
        $.post('/',data,function(data){
        	Ha.reableForm('set_dnscdn');
        	Ha.showNotify(data);
        	$('#switch_assist_dns,#switch_socks5tproxy').parent().removeClass('disabled');
        },'json');
        //Ha.ajax('/','json',data,'post','set_dnscdn',Ha.showNotify,1);
      }
    });

    $('#chinadns_ips').bind('keyup blur',function(){
      var val = $(this).val();
      validateFuc($(this),validateIPS(val));
      disableBtn();
    });
    $('#dns_forwader_ip').bind('keyup blur',function(){
      var val = $(this).val();
      validateFuc($(this),va.validateIP(val));
      disableBtn();
    });
    function validateFuc(target,condation){
      if(condation){
        target.parent().parent().addClass('has-error');
        target.next('.help-block').removeClass('hidden');
      }else{
        target.parent().parent().removeClass('has-error');
        target.next('.help-block').addClass('hidden');
      }
    }
    function validateIPS(str){
      var errorCode = 0;
      var arr = str.split(',');
      for(var i=0; i<arr.length; i++){
        if(va.validateIP(arr[i])){
          errorCode += 1;
        }
      }
      return errorCode;
    }
    function disableBtn(){
      var sum = 0;
      var ips = $('#chinadns_ips').val();
      var ip = $('#dns_forwader_ip').val();
      if(va.validateIP(ip) || validateIPS(ips)){
        $('#submit_btn').prop('disabled',true);
        sum += 1;
      }else{
        $('#submit_btn').prop('disabled',false);
      }
      return sum;
    }
</script>
</body>
</html>
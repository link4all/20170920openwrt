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
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
    	<div class="row">
    		<div class="col-sm-6">
          <div class="app row app-item">
            <h2 class="app-sub-title col-sm-12">Telnet <%= ${_LANG_Form_Base_Setting} %></h2>
            <div class="col-sm-offset-2 col-sm-10 text-left">
                <p>Telnetd <%= ${_LANG_Form_Enabled} %></p>
                <div class="row">
                    <div class="col-xs-3 col-sm-9 col-md-2">
                        <label for="" class=""><%= ${_LANG_Form_Status} %>:</label>
                    </div>
                    <div class="col-xs-9 col-sm-9 col-md-10">
                        <div class="switch-ctrl head-switch" id="switch_telnetd_radio0" data-toggle="modal" data-target="#confirmModal">
                            <input type="checkbox" id="switch_telnetd" <% base_dir="/usr/shellgui/shellguilighttpd/www/apps/telnetd"; [ $(jshon -Q -e "enabled" < "$base_dir/telnetd.json") -gt 0 ] && printf checked%>>
                            <label for="switch_telnetd"><span></span></label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-offset-2 col-sm-10 text-left">
              <p>Telnet <%= ${_LANG_Form_Use_Port} %></p>
              <div class="row">
                <div class="col-xs-3 col-sm-9 col-md-2">
                    <label for="" class=""><%= ${_LANG_Form_Port} %>:</label>
                </div>
                <div class="col-xs-9 col-sm-9 col-md-10">
                  <form class="form-inline" name="use_port" id="use_port">
                      <div class="form-group" id="port_container">
          			        <input type="number" required min="1" max="65535" class="form-control" name="port" value=<% jshon -Q -e "port" < "$base_dir/telnetd.json" || printf 23 %> >
                      </div>
                      <div class="form-group">
                          <button type="submit" id="submit_port" class="btn btn-default btn-block"><%= ${_LANG_Form_Apply} %></button>
                      </div>
                      <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
                  </form>
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
        <h4 class="modal-title">Telnetd <%= ${_LANG_Form_Status} %></h4>
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
<script>
  var UI = {};
  UI.switchOn = 'Telnetd <%= ${_LANG_Form_Enabled} %>?';
  UI.switchOff = 'Telnetd <%= ${_LANG_Form_Disabled} %>?';
</script>
<script src="/apps/telnetd/telnetd.js"></script>
</body>
</html>
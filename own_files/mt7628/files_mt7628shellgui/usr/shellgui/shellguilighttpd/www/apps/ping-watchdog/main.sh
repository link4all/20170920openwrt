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
ping_watchdog_str=$(cat /usr/shellgui/shellguilighttpd/www/apps/ping-watchdog/ping-watchdog.json)
delay_time=$(echo "$ping_watchdog_str" | jshon -e "delay_time")
ping_count=$(echo "$ping_watchdog_str" | jshon -e "ping_count")
host=$(echo "$ping_watchdog_str" | jshon -e "host" -u)
timeout_action=$(echo "$ping_watchdog_str" | jshon -e "timeout_action" -u)
exec_interval=$(echo "$ping_watchdog_str" | jshon -e "exec_interval")
%>
    	<div class="row">
    		<div class="col-sm-6">
    			<div style="margin-bottom: 10px">
					<div class="switch-ctrl" style="margin-left: 1em">
						<input type="checkbox" name="" id="watchdog_switch" value="" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/ping-watchdog/root.cron ] && printf checked %>>
						<label for="watchdog_switch"><span></span></label>
					</div>
					<h4 style="display: inline-block;margin-left: 1em"><%= ${_LANG_Form_Enable_Ping_Watchdog} %></h4>
    			</div>
    			<form id="form_container">
					<div class="form-horizontal">
					  <div class="form-group">
							<label for="host" class="col-sm-4 control-label"><%= ${_LANG_Form_IP_Address_To_Ping} %></label>
							<div class="col-sm-8">
							  <input type="text" class="form-control" id="host" name="host" value="<%= ${host} %>">
							  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_or_domain} %></span>
							</div>
					  </div>
					  <div class="form-group">
							<label for="exec_interval" class="col-sm-4 control-label"><%= ${_LANG_Form_Ping_Interval} %></label>
							<div class="col-sm-8">
								<div class="input-group">
							  	<input type="number" min="1" max="59" class="form-control" id="exec_interval" name="exec_interval" value=<%= ${exec_interval} %>>
									<div class="input-group-addon">minutes</div>
								</div>
							  <span class="help-block hidden"><%= ${_LANG_Form_Between_1_59} %></span>
							</div>
					  </div>
					  <div class="form-group">
							<label for="delay_time" class="col-sm-4 control-label"><%= ${_LANG_Form_Startup_Delay} %></label>
							<div class="col-sm-8">
								<div class="input-group">
							  	<input type="number" min="1" class="form-control" id="delay_time" name="delay_time" value=<%= ${delay_time} %>>
									<div class="input-group-addon">seconds</div>
								</div>
							  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
							</div>
					  </div>
					  <div class="form-group">
							<label for="ping_count" class="col-sm-4 control-label"><%= ${_LANG_Form_Failure_ping_count} %></label>
							<div class="col-sm-8">
							  <input type="number" min="1" class="form-control" id="ping_count" name="ping_count" value=<%= ${ping_count} %>>
							  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
							</div> 
					  </div>
					  <div class="form-group">
							<label for="timeout_action" class="col-sm-4 control-label"><%= ${_LANG_Form_Action} %></label>
							<div class="col-sm-8">
							  <select class="form-control" name="timeout_action" id="timeout_action">
									<option value="wan" <% [ "$timeout_action" = "wan" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WAN_Reconnect} %></option>
									<option value="reboot" <% [ "$timeout_action" = "reboot" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Reboot} %></option>
									<option value="exec_custom" <% [ "$timeout_action" = "wan" ] || [ "$timeout_action" = "reboot" ] || printf 'selected="selected"' %>><%= ${_LANG_Form_Run_custom_script} %></option>
							  </select>
							</div>
					  </div>
					  <div class="form-group <% ([ "$timeout_action" = "wan" ] || [ "$timeout_action" = "reboot" ]) && printf "hidden" %>" id="custom_script">
							<label for="script" class="col-sm-4 control-label"><%= ${_LANG_Form_Script} %></label>
							<div class="col-sm-8">
							  <input type="text" class="form-control" id="script" name="script" value="<% [ "$timeout_action" = "wan" ] || [ "$timeout_action" = "reboot" ] || printf "$timeout_action" %>">
							  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Path} %></span>
							</div> 
					  </div>
					</div>
					<hr>
					<div class="pull-right">
						<button type="submit" class="btn btn-default btn-lg" id="submit_btn"><%= ${_LANG_Form_Apply} %></button>
					</div>
				</form>
    		</div>
    	</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/ping-watchdog/watchdog.js"></script>
</body>
</html>
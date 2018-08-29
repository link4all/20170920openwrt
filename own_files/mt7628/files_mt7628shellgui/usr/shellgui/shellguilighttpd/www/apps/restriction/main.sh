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
		<div class="content">
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Access_Restrictions} %></h2>
				<div class="col-sm-offset-2 col-sm-10 text-left">
					<div class="table-responsive">
						<table class="table">
							<caption><%= ${_LANG_Form_Current_Restrictions} %></caption>
							<thead>
								<tr>
									<th><%= ${_LANG_Form_Rule_Description} %></th>
									<th><%= ${_LANG_Form_Enabled} %></th>
									<th></th>
									<th></th>
								</tr>
							</thead>
							<tbody id="rule_table_container"></tbody>
							<tfoot>
								<tr>
									<td colspan="4">
										<button id="add_new_restrictions_btn" class="btn btn-success btn-sm" data-toggle="modal" data-target="#formModal"><%= ${_LANG_Form_Add_New_Rule} %></button>
									</td>
								</tr>
							</tfoot>
						</table>
					</div>
				</div>
			</div>
			<hr>
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Exceptions__White_List} %></h2>
				<div class="col-sm-offset-2 col-sm-10 text-left">
					<div class="table-responsive">
						<table class="table">
							<caption><%= ${_LANG_Form_Current_Exceptions} %></caption>
							<thead>
								<tr>
									<th><%= ${_LANG_Form_Rule_Description} %></th>
									<th><%= ${_LANG_Form_Enabled} %></th>
									<th></th>
									<th></th>
								</tr>
							</thead>
							<tbody id="exception_table_container"></tbody>
							<tfoot>
								<tr>
									<td colspan="4">
										<button id="add_new_exceptions_btn" class="btn btn-success btn-sm" data-toggle="modal" data-target="#formModal"><%= ${_LANG_Form_Add_New_Rule} %></button>
									</td>
								</tr>
							</tfoot>
						</table>
					</div>
				</div>
			</div>
			<hr>
			<div class="app row app-item pull-right">
				<button class="btn btn-default btn-lg" id="save_page_btn"><%= ${_LANG_Form_Apply} %></button>
				<button class="btn btn-warning btn-lg" id="reset_page_btn"><%= ${_LANG_Form_Reset} %></button>
			</div>
		</div>
	</div> 
</div>
<div class="modal fade" id="formModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="formModalLabel">Modal title</h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal">
        	<div class="form-group">
        		<label for="name" class="control-label col-sm-4"><%= ${_LANG_Form_Rule_Description} %></label>
        		<div class="col-sm-8">
        			<input type="text" id="name" class="form-control">
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Rule_Applies_To} %></label>
        		<div class="col-sm-8">
        			<select name="" id="applies_to_type" data-iptype="applies_to_addr" class="form-control">
        				<option value="all"><%= ${_LANG_Form_All_Hosts} %></option>
        				<option value="except"><%= ${_LANG_Form_All_Hosts_Except} %></option>
        				<option value="only"><%= ${_LANG_Form_Only_The_Following_Host} %></option>
        			</select>
        		</div>
        	</div>
            <div class="form-group hidden">
                <div class="col-sm-offset-4 col-sm-8">
                    <div id="ip_span_container"></div>
                </div>
            </div>
            <div class="form-group hidden" id="add_local_ip_form_group">
                <label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Effective_Hosts} %></label>
                <div class="col-sm-8">
                    <div class="input-group">
                        <div class="row">
                            <div class="col-xs-9">
                                <input type="text" id="applies_to_addr" class="form-control">
                            </div>
                            <div class="col-xs-3">
                                <button type="button" class="add_ip_btn btn btn-success" id="add_local_ip_btn">
                                    <span class="glyphicon glyphicon-plus"></span>
                                </button>
                            </div>
                        </div>
                        <span class="help-block"><%= ${_LANG_Form_Specify_an_IP__IP_range_or_MAC_address_and_add_to_list} %></span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Schedule} %></label>
                <div class="col-sm-8">
                    <div class="row">
                        <div class="col-sm-6">
                            <label for="all_day">
                                <input type="checkbox" id="all_day" checked><%= ${_LANG_Form_All_Day} %>
                            </label>
                            <label for="every_day">
                                <input type="checkbox" id="every_day" checked><%= ${_LANG_Form_Every_Day} %>
                            </label>
                        </div>
                        <div class="col-sm-6">
                            <select id="schedule_repeats" class="form-control">
                                <option value="daily"><%= ${_LANG_Form_Repeats_Daily} %></option>
                                <option value="weekly"><%= ${_LANG_Form_Repeats_Weekly} %></option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-group" id="days_container">
                <label for="" class="control-label col-sm-4">Days Active</label>
                <div class="col-sm-8">
                    <label for="rule_sun"><input type="checkbox" id="rule_sun" value="sunday" checked><%= ${_LANG_Form_Sun} %></label>&nbsp;
                    <label for="rule_mon"><input type="checkbox" id="rule_mon" value="monday" checked><%= ${_LANG_Form_Mon} %></label>&nbsp;
                    <label for="rule_tue"><input type="checkbox" id="rule_tue" value="tuesday" checked><%= ${_LANG_Form_Tue} %></label>&nbsp;
                    <label for="rule_wed"><input type="checkbox" id="rule_wed" value="wednesday" checked><%= ${_LANG_Form_Wed} %></label>&nbsp;
                    <label for="rule_thu"><input type="checkbox" id="rule_thu" value="thursday" checked><%= ${_LANG_Form_Thu} %></label>&nbsp;
                    <label for="rule_fri"><input type="checkbox" id="rule_fri" value="friday" checked><%= ${_LANG_Form_Fri} %></label>&nbsp;
                    <label for="rule_sat"><input type="checkbox" id="rule_sat" value="satarday" checked><%= ${_LANG_Form_Sat} %></label>
                </div>
            </div>
            <div class="form-group has-feedback" id="hours_active_container">
                <label for="hours_active" class="control-label col-sm-4" id="hours_active_label"><%= ${_LANG_Form_Hours_Active} %></label>
                <div class="col-sm-8">
                    <input type="text" id="hours_active" class="form-control">
                    <span class="help-block">e.g. 00:30-13:15, 14:00-15:00</span>
                    <span class="help-block warn-help hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Time_format} %></span>
                </div>
            </div>
            <div class="form-group has-feedback" id="days_and_hours_active_container">
                <label for="days_and_hours_active" class="control-label col-sm-4" id="days_and_hours_active_label"><%= ${_LANG_Form_Days_And_Hours_Active} %></label>
                <div class="col-sm-8">
                    <input type="text" id="days_and_hours_active" class="form-control">
                    <span class="help-block">e.g. Mon 00:30 - Thu 13:15, Fri 14:00 - Fri 15:00</span>
                    <span class="help-block warn-help hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Time_format} %></span>
                </div>
            </div>
        	
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Restricted_Resources} %></label>
        		<div class="col-sm-8">
        			<input type="checkbox" checked id="all_access">
        			<label for="all_access"><%= ${_LANG_Form_All_Network_Access} %></label>
        		</div>
        	</div>
            <div id="resources_container" class="hidden">
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Remote_IP__s} %></label>
        		<div class="col-sm-8">
        			<select name="" id="remote_ip_type" data-iptype="remote_addr" class="form-control">
        				<option value="all"><%= ${_LANG_Form_Block_All} %></option>
        				<option value="only"><%= ${_LANG_Form_Block_Only} %></option>
        				<option value="except"><%= ${_LANG_Form_Block_All_Except} %></option>
        			</select>
        		</div>
        	</div>
        	<div class="form-group hidden">
        		<div class="col-sm-offset-4 col-sm-8">
        			<div id="remote_ip_span_container"></div>
        		</div>
        	</div>
        	<div class="form-group hidden" id="add_remote_ip_form_group">
                <label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Effective_Hosts} %></label>
        		<div class="col-sm-8">
        			<div class="input-group">
                        <div class="row">
                            <div class="col-xs-9">
            				    <input type="text" id="remote_ip" class="form-control">
                            </div>
                            <div class="col-xs-3">
                				<button type="button" class="btn btn-success add_ip_btn" id="add_remote_ip_btn">
        	        				<span class="glyphicon glyphicon-plus"></span>
                				</button>
                            </div>
                        </div>
                        <span class="help-block"><%= ${_LANG_Form_Specify_an_IP__IP_range_or_MAC_address_and_add_to_list} %></span>
                    </div>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4" id="remote_port_label"><%= ${_LANG_Form_Remote_Port__s} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="remote_port_type" class="form-control">
		        				<option value="all"><%= ${_LANG_Form_Block_All} %></option>
		        				<option value="only"><%= ${_LANG_Form_Block_Only} %></option>
		        				<option value="except"><%= ${_LANG_Form_Block_All_Except} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-6 hidden"  id="remote_port_container">
        					<input type="number" min="1" max="65535" name="" id="remote_port" class="form-control">
                            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
        				</div>
        			</div>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4" id="local_port_label"><%= ${_LANG_Form_Local_Port__s} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="local_port_type" class="form-control">
		        				<option value="all"><%= ${_LANG_Form_Block_All} %></option>
		        				<option value="only"><%= ${_LANG_Form_Block_Only} %></option>
		        				<option value="except"><%= ${_LANG_Form_Block_All_Except} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-6 hidden" id="local_port_container">
        					<input type="number" min="1" max="65535" name="" id="local_port" class="form-control">
                            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
        				</div>
        			</div>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Transport_Protocol} %></label>
        		<div class="col-sm-8">
        			<select name="" id="transport_protocol" class="form-control">
        				<option value="both"><%= ${_LANG_Form_Block_All} %></option>
        				<option value="tcp"><%= ${_LANG_Form_Block_TCP} %></option>
        				<option value="udp"><%= ${_LANG_Form_Block_UDP} %></option>
        			</select>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Application_Protocol} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="app_protocol_type" class="form-control">
		        				<option value="all"><%= ${_LANG_Form_Block_All} %></option>
		        				<option value="only"><%= ${_LANG_Form_Block_Only} %></option>
		        				<option value="except"><%= ${_LANG_Form_Block_All_Except} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-6 hidden">
        					<select name="" id="app_protocol" class="form-control">
		        				<option value='aim '>AIM</option>
								<option value='bittorrent '>BitTorrent</option>
								<option value='dns '>DNS</option>
								<option value='edonkey '>eDonkey</option>
								<option value='fasttrack '>FastTrack</option>
								<option value='ftp '>FTP</option>
								<option value='gnutella '>Gnutella</option>
								<option value='http '>HTTP</option>
								<option value='httpaudio '>HTTP Audio</option>
								<option value='httpvideo '>HTTP Video</option>
								<option value='ident '>Ident</option>
								<option value='imap '>IMAP E-Mail</option>
								<option value='irc '>IRC</option>
								<option value='jabber '>Jabber</option>
								<option value='msnmessenger '>MSN Messenger</option>
								<option value='ntp '>NTP</option>
								<option value='pop3 '>POP3</option>
								<option value='skypeout '>Skype Out Calls</option>
								<option value='skypetoskype '>Skype to Skype</option>
								<option value='smtp '>SMTP E-Mail</option>
								<option value='ssh '>SSH Secure Shell</option>
								<option value='ssl '>SSL Secure Socket</option>
								<option value='vnc '>VNC</option>
								<option value='rtp '>VoIP Audio</option>
		        			</select>
        				</div>
        			</div>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Website_URL__s} %></label>
        		<div class="col-sm-8">
        			<select name="" id="url_type" class="form-control">
        				<option value="all"><%= ${_LANG_Form_Block_All} %></option>
        				<option value="only"><%= ${_LANG_Form_Block_Only} %></option>
        				<option value="except"><%= ${_LANG_Form_Block_All_Except} %></option>
        			</select>
        		</div>
        	</div>
			<div class="table-responsive hidden">
				<table class="table">
					<thead class="hidden">
						<tr>
							<th><%= ${_LANG_Form_URL_Part} %></th>
							<th><%= ${_LANG_Form_Match_Type} %></th>
							<th><%= ${_LANG_Form_Match_Text__Expression} %>(表达式)</th>
							<th></th>
						</tr>
					</thead>
					<tbody id="url_container"></tbody>
				</table>
			</div>
        	<div class="form-group hidden" id="url_match_form_group">
	        	<div class="col-sm-4">
	        		<select id="url_match_type" class="form-control">
						<option value="url_exact"><%= ${_LANG_Form_Full_URL_matches_exactly} %></option>
						<option value="url_contains"><%= ${_LANG_Form_Full_URL_contains} %></option>
						<option value="url_regex"><%= ${_LANG_Form_Full_URL_matches_Regex} %></option>
						<option value="url_domain_exact"><%= ${_LANG_Form_Domain_matches_exactly} %></option>
						<option value="url_domain_contains"><%= ${_LANG_Form_Domain_contains} %></option>
						<option value="url_domain_regex"><%= ${_LANG_Form_Domain_matches_Regex} %></option>
					</select>
	        	</div>
        		<div class="col-sm-8" id="url_input_container">
        			<div class="input-group">
                        <div class="row">
                            <div class="col-xs-9">
        				        <input type="text" id="url_match" class="form-control">
                            </div>
                            <div class="col-xs-3">
                				<button type="button" class="btn btn-success">
        	        				<span class="glyphicon glyphicon-plus add_ip_btn" id="add_url_btn"></span>
                				</button>
                            </div>
                        </div>
                        <span class="help-block hidden" id="url-help"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Content} %></span>
        			</div>
        		</div>
        	</div>
            </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="form_submit_btn">Add</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
var uciOriginal = new UCIContainer();
var UI = {};
<%
/usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
uci -X -c/usr/shellgui/shellguilighttpd/www/apps/restriction/ show restriction_uci | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}' %>
UI.Specify_an_IP__IP_range_or_MAC_address="<%= ${_LANG_Form_Specify_an_IP__IP_range_or_MAC_address_and_add_to_list} %>";
var uci = uciOriginal.clone();
</script>
<script src="/apps/restriction/restriction.js"></script>
</body>
</html>
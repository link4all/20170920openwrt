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
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
endianness=$(shellgui '{"action": "get_endianness"}' | jshon -e "endianness" -u)
iv4_count=$(ls /usr/share/xt_geoip/${endianness}/ | grep -c iv4)

firewall_str=$(uci show -X firewall)
eval $(echo "$firewall_str" | grep -E 'firewall\.cfg[a-z0-9]*\.syn_flood=' | cut -d '.' -f3-)
syn_flood_cfg=$(echo "$firewall_str" | grep -E 'firewall\.cfg[a-z0-9]*\.syn_flood=' | cut -d '.' -f2)

cfg_regx=$(echo "$firewall_str" | grep '=zone$' | grep -Eo 'cfg[a-z0-9]*' | tr '\n' '|' | sed 's/|$//')
wan_zone_cfg=$(echo "$firewall_str" | grep -E ${cfg_regx} | grep -E "name=[\'|\" ]wan[\'|\" ]" | cut -d '.' -f2)
wan_zone_input=$(uci get firewall.${wan_zone_cfg}.input)

Allow_DHCP_Renew_cfg=$(echo "$firewall_str" | grep -E Allow-DHCP-Renew | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_DHCP_Renew_cfg}" | grep -qE "name=[\'|\" ]Allow-DHCP-Renew[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
	Allow_DHCP_Renew_target=$(uci get firewall.${Allow_DHCP_Renew_cfg}.target)
else
	Allow_DHCP_Renew_cfg=;
fi
Allow_Ping_cfg=$(echo "$firewall_str" | grep -E Allow-Ping | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_Ping_cfg}" | grep -qE "name=[\'|\" ]Allow-Ping[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
Allow_Ping_target=$(uci get firewall.${Allow_Ping_cfg}.target)
else
	Allow_Ping_cfg=;
fi

Allow_IGMP_cfg=$(echo "$firewall_str" | grep -E Allow-IGMP | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_IGMP_cfg}" | grep -qE "name=[\'|\" ]Allow-IGMP[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
Allow_IGMP_target=$(uci get firewall.${Allow_IGMP_cfg}.target)
else
	Allow_IGMP_cfg=;
fi

Allow_DHCPv6_cfg=$(echo "$firewall_str" | grep -E Allow-DHCPv6 | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_DHCPv6_cfg}" | grep -qE "name=[\'|\" ]Allow-DHCPv6[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
Allow_DHCPv6_target=$(uci get firewall.${Allow_DHCPv6_cfg}.target)
else
	Allow_DHCPv6_cfg=;
fi

Allow_MLD_cfg=$(echo "$firewall_str" | grep -E Allow-MLD | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_MLD_cfg}" | grep -qE "name=[\'|\" ]Allow-MLD[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
Allow_MLD_target=$(uci get firewall.${Allow_MLD_cfg}.target)
else
	Allow_MLD_cfg=;
fi

Allow_ICMPv6_Input_cfg=$(echo "$firewall_str" | grep -E Allow-ICMPv6-Input | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_ICMPv6_Input_cfg}" | grep -qE "name=[\'|\" ]Allow-ICMPv6-Input[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
Allow_ICMPv6_Input_target=$(uci get firewall.${Allow_ICMPv6_Input_cfg}.target)
else
	Allow_ICMPv6_Input_cfg=;
fi

Allow_ICMPv6_Forward_cfg=$(echo "$firewall_str" | grep -E Allow-ICMPv6-Forward | cut -d '.' -f2)
if echo "$firewall_str" | grep "firewall.${Allow_ICMPv6_Forward_cfg}" | grep -qE "name=[\'|\" ]Allow-ICMPv6-Forward[\'|\" ]|src=[\'|\" ]wan[\'|\" ]"; then
Allow_ICMPv6_Forward_target=$(uci get firewall.${Allow_ICMPv6_Forward_cfg}.target)
else
	Allow_ICMPv6_Forward_cfg=;
fi
cfg_regx=$(echo "$firewall_str" | grep Allow-TCP-Port-Wan | grep -Eo 'cfg[a-z0-9]*' | tr '\n' '|' | sed 's/|$//')
allow_tcp_ports=$(eval echo $(echo "$firewall_str" | grep -E ${cfg_regx} | grep -E "dest_port=" | cut -d '=' -f2 | tr '\n' ',' | sed 's/,$//'))
cfg_regx=$(echo "$firewall_str" | grep Allow-UDP-Port-Wan | grep -Eo 'cfg[a-z0-9]*' | tr '\n' '|' | sed 's/|$//')
allow_udp_ports=$(eval echo $(echo "$firewall_str" | grep -E ${cfg_regx} | grep -E "dest_port=" | cut -d '=' -f2 | tr '\n' ',' | sed 's/,$//'))
cfg_regx=$(echo "$firewall_str" | grep Allow-TCPUDP-Port-Wan | grep -Eo 'cfg[a-z0-9]*' | tr '\n' '|' | sed 's/|$//')
allow_tcpudp_ports=$(eval echo $(echo "$firewall_str" | grep -E ${cfg_regx} | grep -E "dest_port=" | cut -d '=' -f2 | tr '\n' ',' | sed 's/,$//'))
%>
		<div class="content">
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_SYN_flood_Protection} %></h2>
			  <form class="form-horizontal text-left col-sm-12">
			    <div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enable} ${_LANG_Form_SYN_flood_Protection} %></label>
        		<div class="col-sm-8">
				  		<div class="switch-ctrl head-switch" id="switch_syn_flood_radio0" data-toggle="modal" data-target="#confirmModal">
							  <input type="checkbox" name="nic-switch" id="switch_syn_flood" <% [ ${syn_flood} -gt 0 ] && printf 'checked' %>>
							  <label for="switch_syn_flood"><span></span></label>
				  		</div>
        		</div>
        	</div>
				</form>
      </div>
      <div class="app row app-item">
        <h2 class="app-sub-title col-sm-12">Wan <%= ${_LANG_Form_Base_Setting} %></h2>
        <div class="col-sm-offset-2 col-sm-6 text-left">
          <form class="form-horizontal text-left" id="set_firewall">
						<fieldset id="set_dnscdn_form">
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Access_from_External} %></label>
								<div class="col-sm-8">
						  		<div class="switch-ctrl head-switch">
									  <input type="checkbox" name="wan_zone_input" id="wan_zone_input" value="ACCEPT" <% echo "$wan_zone_input" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="wan_zone_input"><span></span></label>
						  		</div>
								</div>
							</div>
							<div id="allow_ports">
								<div class="form-group">
									<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_TCP_Ports} %></label>
									<div class="col-sm-8">
										<input type="text" class="form-control" name="allow_tcp_ports" id="allow_tcp_ports" placeholder="80,22,105-109" value="<%= ${allow_tcp_ports} %>">
										<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port_or_range} %></span>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_UDP_Ports} %></label>
									<div class="col-sm-8">
										<input type="text" class="form-control" name="allow_udp_ports" id="allow_udp_ports" placeholder="53,123" value="<%= ${allow_udp_ports} %>">
										<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port_or_range} %></span>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_TCP_UDP_Ports} %></label>
									<div class="col-sm-8">
										<input type="text" class="form-control" name="allow_tcpudp_ports" id="allow_tcpudp_ports" placeholder="21" value="<%= ${allow_tcpudp_ports} %>">
										<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port_or_range} %></span>
									</div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_DHCP_Renew} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_DHCP_Renew_target" id="Allow_DHCP_Renew_target" value="ACCEPT" <% echo "$Allow_DHCP_Renew_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_DHCP_Renew_target"><span></span></label>
								  </div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_Ping} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_Ping_target" id="Allow_Ping_target" value="ACCEPT" <% echo "$Allow_Ping_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_Ping_target"><span></span></label>
								  </div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_IGMP} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_IGMP_target" id="Allow_IGMP_target" value="ACCEPT" <% echo "$Allow_IGMP_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_IGMP_target"><span></span></label>
								  </div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_DHCPv6} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_DHCPv6_target" id="Allow_DHCPv6_target" value="ACCEPT" <% echo "$Allow_DHCPv6_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_DHCPv6_target"><span></span></label>
								  </div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_MLD} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_MLD_target" id="Allow_MLD_target" value="ACCEPT" <% echo "$Allow_MLD_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_MLD_target"><span></span></label>
								  </div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_ICMPv6_Input} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_ICMPv6_Input_target" id="Allow_ICMPv6_Input_target" value="ACCEPT" <% echo "$Allow_ICMPv6_Input_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_ICMPv6_Input_target"><span></span></label>
								  </div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-4 control-label"><%= ${_LANG_Form_Allow_ICMPv6_Forward} %></label>
								<div class="col-sm-8">
								  <div class="switch-ctrl head-switch">
									  <input type="checkbox" name="Allow_ICMPv6_Forward_target" id="Allow_ICMPv6_Forward_target" value="ACCEPT" <% echo "$Allow_ICMPv6_Forward_target" | grep -q 'ACCEPT' && printf 'checked' %>>
									  <label for="Allow_ICMPv6_Forward_target"><span></span></label>
								  </div>
								</div>
							</div>
<%
for key in syn_flood_cfg wan_zone_cfg Allow_DHCP_Renew_cfg Allow_Ping_cfg Allow_IGMP_cfg Allow_DHCPv6_cfg Allow_MLD_cfg Allow_ICMPv6_Input_cfg Allow_ICMPv6_Forward_cfg; do
%>
<input name="<%= ${key} %>" type="hidden" value="<%= $(eval echo '$'${key}) %>">
<% done %>
							<div class="form-group">
								<div class="col-sm-offset-4 col-sm-8">
									<button type="submit" class="btn btn-default" id="submit_btn"><%= ${_LANG_Form_Apply} %></button>
								</div>
							</div>
						</fieldset>
					</form>
        </div>
			</div>
      <div class="app row app-item">
        <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_GEOIP_Database} %>:</h2>
        <div class="col-sm-offset-2 col-sm-6 text-left">
					<p class="col-sm-12 text-left">
						<span><%= ${_LANG_Form_Update_status} %>: </span><span id="server_status"><% [ ${iv4_count} -gt 200 ] && printf "${_LANG_Form_Updated}" || printf "${_LANG_Form_Need_update}" %></span>
					</p>
					<form id="reload_geoip">
						<p class="col-sm-12 text-left">
							<span><%= ${_LANG_Form_Load_status} %>: </span><span><% lsmod | grep -q 'xt_geoip' && printf "${_LANG_Form_Loaded}" || printf "${_LANG_Form_Unloaded}" %></span>
								<button type="submit" class="btn-link"><%= ${_LANG_Form_Reload} %></button>
						</p>
					</form>
					<% if [ ${iv4_count} -gt 200 ]; then %>
					<p class="col-sm-12 text-left">
						<span><%= ${_LANG_Form_Update_ver} %>: </span><span><% jshon -Q -e "ver" -u -F /usr/share/xt_geoip/last_version %></span>
					</p>
					<p class="col-sm-12 text-left">
						<span><%= ${_LANG_Form_Made_date} %>: </span><span><% date -d @$(jshon -Q -e "timestamp" -u -F /usr/share/xt_geoip/last_version) "+%Y-%m-%d %H:%M:%S" %></span>
					</p>
					<% fi %>
          <form class="form-horizontal text-left">
          	<div class="form-group">
          		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enable_Auto_Update} %></label>
          		<div class="col-sm-8">
							  <div class="switch-ctrl head-switch" id="switch_geoipupdate_radio0" data-toggle="modal" data-target="#confirmModal">
								  <input type="checkbox" name="nic-switch" id="switch_geoipupdate" value="" <% grep -q 'geoip_update' /usr/shellgui/shellguilighttpd/www/apps/firewall-extra/root.cron && printf 'checked' %>>
								  <label for="switch_geoipupdate"><span></span></label>
							  </div>
          		</div>
          	</div>
					</form>
        </div>
        <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Upload_GEOIP_Database__if_cant_auto_update} %>:</h2>
        <div class="col-sm-offset-2 col-sm-6 text-left">
					<div class="col-sm-8">
					  <form class="form-horizontal text-left" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="/apps/firewall-extra/upload.cgi">
						<div class="form-group upload-ctrl">
						  <p><%= ${_LANG_Form_Upload_GEOIP_Database_file} %>:</p>
						  <label for="upload-geoip" class="">
							<p class="btn btn-info"><%= ${_LANG_Form_Browse} %></p>
							<p class="file-name" id="file_name"><%= ${_LANG_Form_Upload_file} %></p>
						  </label>
						  <input type="file" id="upload-geoip" name="file" class="form-control fw-file">
						</div>
						<div class="form-group">
						  <button type="submit" id="submit_file_btn" class="btn btn-default"><%= ${_LANG_Form_Upload} %></button>
						  <span class="upload-progress-bar hidden"><span></span></span>
						</div>
					  </form>
					  <div id="file_info" class="hidden">
	            <label for=""><%= ${_LANG_Form_File_size} %>:</label>
	            <span id="file_size"></span>
	            <br>
	            <label for=""><%= ${_LANG_Form_MIME_Type} %>:</label>
	            <span id="file_type"></span>
	            <br>
	            <label for=""><%= ${_LANG_Form_Upload_progress} %>:</label>
	            <span id="progress-text">0%</span>
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
        <h4 class="modal-title"><%= ${_LANG_Form_GEOIP_Auto_Update_status} %></h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text"></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>

<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/firewall-extra/firewall_extra.js"></script>
<script>
var UI = {};
UI.switch_geoip = '<%= ${_LANG_Form_GEOIP_Auto_Update} %>';
UI.switchOn_geoip = '<%= ${_LANG_Form_Enable} ${_LANG_Form_GEOIP_Auto_Update} %>?';
UI.switchOff_geoip = '<%= ${_LANG_Form_Disable} ${_LANG_Form_GEOIP_Auto_Update} %>?';
UI.syn_flood_cfg = '<%= ${syn_flood_cfg} %>';
UI.switch_syn_flood = '<%= ${_LANG_Form_SYN_flood_Protection} %>';
UI.switchOn_syn_flood = '<%= ${_LANG_Form_Enable} ${_LANG_Form_SYN_flood_Protection} %> ?';
UI.switchOff_syn_flood = '<%= ${_LANG_Form_Disable} ${_LANG_Form_SYN_flood_Protection} %>?';
</script>
</body>
</html>
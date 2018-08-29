#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "download_client_key" ] &>/dev/null; then
	if [ ! -d "/etc/openvpn/client_conf/$FORM_id" ] ; then
		printf "Content-Type: text/html;\r\n charset=utf-8;\r\n\r\nERROR: Client ID does not exist."
	else
		cd "/etc/openvpn/client_conf/$FORM_id" >/dev/null 2>&1
		7za a /tmp/vpn.ac.tmp.7z * >/dev/null 2>&1
		cat /tmp/vpn.ac.tmp.7z | /usr/shellgui/progs/main.sbin http_download openvpn-keys-$FORM_id.7z
		rm /tmp/vpn.ac.tmp.7z >/dev/null 2>&1
	fi
return
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<%
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
if [ $(uci get openvpn.custom_config.enabled) -gt 0 ]; then
	if uci get openvpn.custom_config.config | grep -q server; then
		real_at='ser'
	else
		real_at='cli'
	fi
else
	real_at='dis'
fi
if [ -n "$FORM_active" ]; then
	eval li_${FORM_active}_at='class="active"'
	eval tab_${FORM_active}_at='active'
else
	eval li_${real_at}_at='class="active"'
	eval tab_${real_at}_at='active'
fi %>
<div class="content">
	<div class="app row app-item">
		<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_OpenVPN_Status} %></h2>
		<div class="col-sm-offset-1 col-sm-6">
			<div class="table-responsive  text-left">
				<p><%= ${_LANG_Form_Mode} %>: <% eval echo '$_LANG_Form_'${real_at} %></p>
				<p><% pidof openvpn &>/dev/null && printf "${_LANG_Form_Running}," || printf "${_LANG_Form_Not_running}";tun_ip=$(shellgui '{"action":"get_ifces_status"}'| jshon -e "tun0" -e "ip" -u); [ -n "${tun_ip}" ] && printf "${_LANG_Form_Connected__IP}: ${tun_ip}" %></p>
			</div>
		</div>
	</div>
</div>
		<ul class="nav nav-tabs">
			<li <%= ${li_ser_at} %>>
	        	<a href="#vpn_server" data-toggle="tab">
	        		<%= ${_LANG_Form_ser} %>
	        	</a>
			</li>
			<li <%= ${li_cli_at} %>>
				<a href="#vpn_client" data-toggle="tab">
	        		<%= ${_LANG_Form_cli} %>
	        	</a>
			</li>
			<li <%= ${li_dis_at} %>>
				<a href="#vpn_disabled" data-toggle="tab">
	        		<%= ${_LANG_Form_dis} %>
	        	</a>
			</li>
		</ul>
<% eval $(uci -c/usr/shellgui/shellguilighttpd/www/apps/openvpn show openvpn_uci.server | cut -d '.' -f3-) %>
		<div class="tab-content">
			<div class="tab-pane <%= ${tab_ser_at} %>" id="vpn_server">
				<div class="app row app-item">
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Server_setting} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<form class="form-horizontal text-left" name="set_openvpn_server" id="set_openvpn_server">
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_OpenVPN_Internal_IP} %>:</label>
						    <div class="col-sm-8">
						      <input type="text" class="form-control" name="internal_ip" value="<%= ${internal_ip} %>" placeholder="10.8.0.1">
						    </div>
						  </div>
						  <div class="form-group">
						  <label class="col-sm-4 control-label"><%= ${_LANG_Form_OpenVPN_Internal_Subnet_Mask} %></label>
						    <div class="col-sm-8">
						      <input type="text" class="form-control" name="internal_mask" value="<%= ${internal_mask} %>" placeholder="255.255.255.0">
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_OpenVPN_Port} %></label>
						    <div class="col-sm-8">
						      <input type="text" class="form-control" name="port" value="<%= ${port} %>" placeholder="1194">
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_OpenVPN_Protocol} %></label>
						    <div class="col-sm-8">
								<select name="proto" class="form-control">
									<option value="udp" <% [ "${proto}" = "udp" ] && printf 'selected="selected"' %>>UDP</option>
									<option value="tcp" <% [ "${proto}" = "tcp" ] && printf 'selected="selected"' %>>TCP</option>
								</select>
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_OpenVPN_Cipher} %></label>
						    <div class="col-sm-8">
								<select name="cipher" class="form-control">
									<option value="BF-CBC:128" <% [ "${cipher}" = "BF-CBC" ] && [ ${keysize} -eq 128 ] && printf 'selected="selected"' %>>Blowfish-CBC 128bit</option>
									<option value="BF-CBC:256" <% [ "${cipher}" = "BF-CBC" ] && [ ${keysize} -eq 256 ] && printf 'selected="selected"' %>>Blowfish-CBC 256bit</option>
									<option value="AES-128-CBC" <% [ "${cipher}" = "AES-128-CBC" ] && printf 'selected="selected"' %>>AES-CBC 128bit</option>
									<option value="AES-256-CBC" <% [ "${cipher}" = "AES-256-CBC" ] && printf 'selected="selected"' %>>AES-CBC 256bit</option>
								</select>
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_Client_To_Client_Traffic} %></label>
						    <div class="col-sm-8">
								<select name="client_to_client" class="form-control">
									<option value="true"><%= ${_LANG_Form_Allow_Clients_To_Communicate_With_Each_Other} %></option>
									<option value="false" <% [ "${client_to_client}" = "false" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Clients_Can_Only_Communicate_With_Server} %></option>
								</select>
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_LAN_Subnet_Access} %></label>
						    <div class="col-sm-8">
								<select name="subnet_access" class="form-control">
									<option value="true"><%= ${_LANG_Form_Allow_Clients_To_Access_Hosts_on_LAN} %></option>
									<option value="false" <% [ "${subnet_access}" = "false" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Clients_Can_Not_Access_LAN} %></option>
								</select>
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_Credential_Re_Use} %></label>
						    <div class="col-sm-8">
								<select name="duplicate_cn" class="form-control">
									<option value="false"><%= ${_LANG_Form_Credentials_Are_Specific_to_Each_Client} %></option>
									<option value="true" <% [ "${duplicate_cn}" = "true" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Credentials_Can_Be_Used_By_Multiple_Clients} %></option>
								</select>
						    </div>
						  </div>
						  <div class="form-group">
						    <label class="col-sm-4 control-label"><%= ${_LANG_Form_Clients_Use_VPN_For} %></label>
						    <div class="col-sm-8">
								<select name="redirect_gateway" class="form-control">
									<option value="true"><%= ${_LANG_Form_All_Client_Traffic} %></option>
									<option value="false" <% [ "${redirect_gateway}" = "false" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Only_Traffic_Destined_for_Hosts_Behind_VPN} %></option>
								</select>
						    </div>
						  </div>
						  <div class="form-group">
						    <div class="col-sm-offset-4 col-sm-8">
						      <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
						    </div>
						  </div>
						</form>
					</div>
				</div>
				<hr>
				<div class="app row app-item">
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Allowed_Clients} %></h2>
					<div class="col-sm-offset-1 col-sm-11">
						<div class="table-responsive">
							<table class="table">
								<caption><%= ${_LANG_Form_Currently_Configured_Clients} %></caption>
							    <thead>
							        <tr>
							            <th><%= ${_LANG_Form_Client_Name} %></th>
							            <th><%= ${_LANG_Form_Internal_IP__Routed_Subnet} %></th>
							            <th><%= ${_LANG_Form_Enabled} %></th>
							            <th><%= ${_LANG_Form_Credentials__Config_Files} %></th>
							            <th></th>
							            <th></th>
							        </tr>
							    </thead>
							    <tbody class="text-left" id="client_container"></tbody>
							    <tfoot class="text-left">
							    	<tr>
							    		<td colspan="6">
							    			<button class="btn btn-success" id="add_new_client_btn" data-toggle="modal" data-target="#formModal"><%= ${_LANG_Form_Add_New_Client} %></button>
							    		</td>
							    	</tr>
							    </tfoot>
							</table>
						</div>
					</div>
				</div>
			</div>
			<div class="tab-pane <%= ${tab_cli_at} %>" id="vpn_client">
				<div class="app row app-item">
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Upload_Client_Configuration_File} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
				  	<div id="uploader-container" class="text-left" data-action="/apps/openvpn/upload.cgi" data-label=""></div>
					</div>
				</div>
				<div class="app row app-item">
				  <form class="form-horizontal text-left" name="set_openvpn_client" id="set_openvpn_client">
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_OpenVPN_Configuration} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<textarea class="form-control" name="openvpn_client_conf_text" id="sig" rows="5" placeholder="OpenVPN Configuration"><% [ -f /etc/openvpn/client.conf ] && conf_file="/etc/openvpn/client.conf" || conf_file="/etc/openvpn/client.conf.bak" ;cat ${conf_file} %></textarea>
						</div>
					</div>
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_CA_Certificate} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<textarea class="form-control" name="openvpn_client_ca_text" id="sig" rows="5" placeholder="CA Certificate"><% cat /etc/openvpn/client_ca.crt %></textarea>
						</div>
					</div>
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Client_Certificate} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<textarea class="form-control" name="openvpn_client_cert_text" id="sig" rows="5" placeholder="Client Certificate"><% cat /etc/openvpn/client.crt %></textarea>
						</div>
					</div>
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Client_Key} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<textarea class="form-control" name="openvpn_client_key_text" id="sig" rows="5" placeholder="Client Key"><% cat /etc/openvpn/client.key %></textarea>
						</div>
					</div>
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_TLS_Auth_Key} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<textarea class="form-control" name="openvpn_client_ta_key_text" id="sig" rows="5" placeholder="TLS-Auth Key"><% cat /etc/openvpn/client_ta.key %></textarea>
						</div>
					</div>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
						</div>
					</div>
				  </form>
				</div>
			</div>
			<div class="tab-pane <%= ${tab_dis_at} %>" id="vpn_disabled">
			<div class="app row app-item">
				<% if echo "${real_at}" | grep -qE 'ser|cli'; then %>
				  <form class="form-horizontal text-left" name="disable_openvpn" id="disable_openvpn">
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Disable_OpenVPN} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<p><%= ${_LANG_Form_Disable_OpenVPN} %></p>
						</div>
					</div>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
						</div>
					</div>
				  </form>
				  <% else %>
				  <form class="form-horizontal text-left" name="clean_keys" id="clean_keys">
					<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Clear_All_Existing_OpenVPN_Keys} %></h2>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<p><%= ${_LANG_Form_Clear_All_Existing_OpenVPN_Keys} %></p>
						</div>
					</div>
					<div class="col-sm-offset-1 col-sm-6">
						<div class="table-responsive">
							<button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
						</div>
					</div>
				  </form>
				  <% fi %>
				</div>
			</div>
		</div>
	</div> 
</div>
<div class="modal fade" id="formModal" tabindex="-1">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id="formModalLabel"><%= ${_LANG_Form_Configure_A_New_Client_Set_of_Credentials} %></h4>
			</div>
			<div class="modal-body">
        		<form class="form-horizontal" id="clientForm">
					<div class="form-group">
						<label for="client_name" class="col-sm-4 control-label"><%= ${_LANG_Form_Client_Name} %>:</label>
						<div class="col-sm-8">
							<input type="text" class="form-control" name="title" id="client_name">
						</div>
					</div>
					<div class="form-group">
						<label for="client_ip" class="col-sm-4 control-label"><%= ${_LANG_Form_Internal_IP__Routed_Subnet} %></label>
						<div class="col-sm-8">
							<input type="text" class="form-control" name="ip" id="client_ip" >
						</div>
					</div>
					<div class="form-group">
						<label for="proto" class="col-sm-4 control-label"><%= ${_LANG_Form_Remote} %></label>
						<div class="col-sm-8">
							<input type="text" id="proto"  class="form-control">
						</div>
					</div>
					<div class="form-group">
						<label for="cipher" class="col-sm-4 control-label"><%= ${_LANG_Form_Subnet_Behind_Client} %></label>
						<div class="col-sm-8">
							<select id="cipher" class="form-control">
								<option value="false"><%= ${_LANG_Form_No_Subnet_Defined} %></option>
								<option value="true"><%= ${_LANG_Form_Route_The_Subnet_Below} %></option>
							</select>
						</div>
					</div>
					<div id="subnet_container" class="hidden">
						<div class="form-group">
							<label for="subnet_ip" class="col-sm-4 control-label"><%= ${_LANG_Form_Subnet_IP} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="subnet_ip">
							</div>
						</div>
						<div class="form-group">
							<label for="subnet_mask" class="col-sm-4 control-label"><%= ${_LANG_Form_Subnet_Mask} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="subnet_mask">
							</div>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" id="submit_client_btn"><%= ${_LANG_Form_Add} %></button>
				<button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
			</div>
		</div>
	</div>
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.Upload_file = '<%= ${_LANG_Form_Upload_file} %>';
UI.Browse = '<%= ${_LANG_Form_Browse} %>';
UI.Upload = '<%= ${_LANG_Form_Upload} %>';
UI.File_Size = '<%= ${_LANG_Form_File_Size} %>';
UI.File_Format = '<%= ${_LANG_Form_File_Format} %>';
UI.Upload_Progress = '<%= ${_LANG_Form_Upload_Progress} %>';
</script>
<% /usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/home/common/js/jquery.form.js"></script>
<script>
var uciOriginal = new UCIContainer();
<%
uci -c/usr/shellgui/shellguilighttpd/www/apps/openvpn show -X openvpn_uci | grep -E 'openvpn_uci.client' | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
%>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
  (function(){
    Components.makeUploader($('#uploader-container'),function(xhr){
    	console.log(xhr.responseText);
	    // var data = $.parseJSON(xhr.responseText);
	    // data.status = parseInt(data.status);
	    // data.seconds = parseInt(data.seconds);
	    // Ha.showNotify(data);
	    // setTimeout(function(){
	    //   window.location.href = data.jump_url;
	    // },data.seconds);
    });
    $('#disable_openvpn').submit(function(e){
      e.preventDefault();
      var data = "app=openvpn&action=disable_openvpn";
      Ha.disableForm('disable_openvpn');
      Ha.ajax('/','json',data,'post','disable_openvpn',Ha.showNotify,1);
    });
    $('#clean_keys').submit(function(e){
      e.preventDefault();
      var data = "app=openvpn&action=clean_keys";
      Ha.disableForm('clean_keys');
      Ha.ajax('/','json',data,'post','clean_keys',Ha.showNotify,1);
    });
  })();
</script>
<script src="/apps/openvpn/openvpn.js"></script>
</body>
</html>

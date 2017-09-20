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
        <div class="content">
            <div class="app row app-item">
                <h2 class="app-sub-title col-sm-12">Shadowsocks <%= ${_LANG_Form_Server} %></h2>
				<p class="col-sm-12 text-left">
					<span><%= ${_LANG_Form_Status} %>: </span><span id="server_status"><%= ${_LANG_Form_Not_Runed} %></span>
				</p>
                <div class="col-sm-offset-2 col-sm-6 text-left">
                    <form class="form-horizontal text-left" id="set_shadowvpn_server">
                    	<div class="form-group">
                    		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enabled} %></label>
                    		<div class="col-sm-8">
 		                   		<div class="switch-ctrl switch-sm">
                    				<input type="checkbox" class="" id="server_enabled"><label for="server_enabled"><span></span></label>
 		                   		</div>
                    		</div>
                    	</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Server_bind_IP} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="server_bind_ip">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Server_bind_Port} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="server_bind_port">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Password} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="server_password">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Timeout} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="server_timeout">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Enc_Method} %></label>
							<div class="col-sm-8">
								<select class="form-control" id="enc_method">
									<option value="table" >TABLE</option>
									<option value="rc4" >RC4</option>
									<option value="rc4-md5" >RC4-MD5</option>
									<option value="aes-128-cfb" >AES-128-CFB</option>
									<option value="aes-192-cfb" >AES-192-CFB</option>
									<option value="aes-256-cfb" >AES-256-CFB</option>
									<option value="bf-cfb" >BF-CFB</option>
									<option value="camellia-128-cfb" >CAMELLIA-128-CFB</option>
									<option value="camellia-192-cfb" >CAMELLIA-192-CFB</option>
									<option value="camellia-256-cfb" >CAMELLIA-256-CFB</option>
									<option value="cast5-cfb" >CAST5-CFB</option>
									<option value="des-cfb" >DES-CFB</option>
									<option value="idea-cfb" >IDEA-CFB</option>
									<option value="rc2-cfb" >RC2-CFB</option>
									<option value="seed-cfb" >SEED-CFB</option>
									<option value="salsa20" >SALSA20</option>
									<option value="chacha20" >CHACHA20</option>
								</select>
							</div>
						</div>
					</form>
                </div>
            </div>
        </div>
        <hr>
        <div class="content">
            <div class="app row app-item">
                <h2 class="app-sub-title col-sm-12">Shadowsocks <%= ${_LANG_Form_Local} %></h2>
				<p class="col-sm-12 text-left">
					<span><%= ${_LANG_Form_Status} %>: </span><span id="local_status"><%= ${_LANG_Form_Not_Runed} %></span>
				</p>
                <div class="col-sm-offset-2 col-sm-6 text-left">
                    <div class="form-horizontal">
                    	<div class="form-group">
                    		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enabled} %></label>
                    		<div class="col-sm-8">
                    			<div class="switch-ctrl switch-sm">
                    				<input type="checkbox" class="" id="local_enabled">
                    				<label for="local_enabled"><span></span></label>
 		                   		</div>
                    		</div>
                    	</div>
                    	<div class="form-group">
                    		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Select_Config} %></label>
                    		<div class="col-sm-8">
                    			<select class="form-control" id="local_config"></select>
                    		</div>
                    	</div>
                    </div>
                </div>
            </div>
        </div>
        <hr>
        <div class="content">
            <div class="app row app-item">
                <h2 class="app-sub-title col-sm-12">Shadowsocks <%= ${_LANG_Form_Redir} %></h2>
				<p class="col-sm-12 text-left">
					<span><%= ${_LANG_Form_Status} %>: </span><span id="redir_status"><%= ${_LANG_Form_Not_Runed} %></span>
				</p>
                <div class="col-sm-offset-2 col-sm-6 text-left">
                    <div class="form-horizontal">
                    	<div class="form-group">
                    		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enabled} %></label>
                    		<div class="col-sm-8">
                    			<div class="switch-ctrl switch-sm">
                    				<input type="checkbox" class="" id="redir_enabled">
                    				<label for="redir_enabled"><span></span></label>
 		                   		</div>
                    		</div>
                    	</div>
                    	<div class="form-group">
                    		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Select_Config} %></label>
                    		<div class="col-sm-8">
                    			<select class="form-control" id="redir_config"></select>
                    		</div>
                    	</div>
						<hr>
						<div class="form-group">
							<h4 class="col-sm-4"><%= ${_LANG_Form_External_network_rules} %></h4>
							<div class="col-sm-8"></div>
						</div>
						<div class="form-group">
						<label class="col-sm-4 control-label"><%= ${_LANG_Form_Excepted_Countries} %></label>
							<div class="col-sm-8">
								<input type="text" class="form-control" id="geoip_cc">
								<pre class="help-block hidden"><% endianness=$(shellgui '{"action": "get_endianness"}' | jshon -e "endianness" -u); ls /usr/share/xt_geoip/${endianness}/*.iv4 | sed -e 's#^.*/##g' -e 's#\..*$##g' | tr '\n' ',' %></pre>
							</div>
						</div>
						<div class="form-group">
						<label class="col-sm-4 control-label"><%= ${_LANG_Form_Exceptions_IPs} %></label>
							<div class="col-sm-8">
								<textarea class="form-control" id="hit_ips" rows="3"></textarea>
								<p class="help-block hidden"><%= ${_LANG_Form_Use_wrap_on_multiple_IPs} %></p>
							</div>
						</div>
						<hr>
						<div class="form-group">
							<h4 class="col-sm-4"><%= ${_LANG_Form_Internal_network_rules} %></h4>
							<div class="col-sm-8"></div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Global_mode_of_Internal_Network} %></label>
							<div class="col-sm-8">
								<div class="switch-ctrl switch-sm">
                    				<input type="checkbox" class="" id="internal_mode">
                    				<label for="internal_mode"><span></span></label>
 		                   		</div>
								<p><%= ${_LANG_Form_Below_options_will_take_effect_aft_Turn_it_off} %></p>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Effective_IPs} %></label>
							<div class="col-sm-8">
								<textarea class="form-control" id="internal_hit_ips" rows="3"></textarea>
								<p class="help-block hidden"><%= ${_LANG_Form_Use_wrap_on_multiple_IPs} %></p>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-4 control-label"><%= ${_LANG_Form_Exceptions_IPs} %></label>
							<div class="col-sm-8">
								<textarea class="form-control" id="internal_except_ips" rows="3"></textarea>
								<p class="help-block hidden"><%= ${_LANG_Form_Use_wrap_on_multiple_IPs} %></p>
							</div>
						</div>
                    </div>
                </div>
            </div>
        </div>
        <hr>
		<div class="content">
            <div class="app row app-item">
                <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Configuration_list} %></h2>
                <div class="col-sm-offset-2 col-sm-10 text-left">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th><%= ${_LANG_Form_Desc} %></th>
                                    <th><%= ${_LANG_Form_Edit} %></th>
                                    <th><%= ${_LANG_Form_Remove} %></th>
                                </tr>
                            </thead>
                            <tbody id="config_container"></tbody>
                            <tfoot>
                            	<tr>
                            		<td colspan="3">
                            			<button id="add_config_btn" class="btn btn-success" data-toggle="modal" data-target="#configModal"><%= ${_LANG_Form_Add_New_Config} %></button>
                            		</td>
                            	</tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>
        </div>
		<hr>
		<div class="content">
            <div class="app row app-item">
            	<button class="btn btn-warning btn-lg pull-right" id="reset_page_btn"><%= ${_LANG_Form_Reset} %></button>
            	<button class="btn btn-default btn-lg pull-right" id="save_page_btn"><%= ${_LANG_Form_Apply} %></button>
            </div>
        </div>
	</div> 
</div>
<div class="modal fade" id="configModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="configModalLabel">Title</h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal">
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Desc} %></label>
        		<div class="col-sm-8">
        			<input type="text" class="form-control" id="config_desc">
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Server_bind_IP} %></label>
        		<div class="col-sm-8">
        			<input type="text" class="form-control" id="config_server_ip">
        		</div>
        	</div>
        	<div class="form-group">
				<label class="col-sm-4 control-label"><%= ${_LANG_Form_Server_bind_Port} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" id="config_server_port">
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-4 control-label"><%= ${_LANG_Form_Password} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" id="config_password">
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-4 control-label"><%= ${_LANG_Form_Local_bind_IP} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" id="config_local_ip">
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-4 control-label"><%= ${_LANG_Form_Local_bind_Port} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" id="config_local_port">
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-4 control-label"><%= ${_LANG_Form_Timeout} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" id="config_timeout">
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-4 control-label"><%= ${_LANG_Form_Enc_Method} %></label>
				<div class="col-sm-8">
					<select class="form-control" id="config_enc_method">
						<option value="table" >TABLE</option>
						<option value="rc4" >RC4</option>
						<option value="rc4-md5" >RC4-MD5</option>
						<option value="aes-128-cfb" >AES-128-CFB</option>
						<option value="aes-192-cfb" >AES-192-CFB</option>
						<option value="aes-256-cfb" >AES-256-CFB</option>
						<option value="bf-cfb" >BF-CFB</option>
						<option value="camellia-128-cfb" >CAMELLIA-128-CFB</option>
						<option value="camellia-192-cfb" >CAMELLIA-192-CFB</option>
						<option value="camellia-256-cfb" >CAMELLIA-256-CFB</option>
						<option value="cast5-cfb" >CAST5-CFB</option>
						<option value="des-cfb" >DES-CFB</option>
						<option value="idea-cfb" >IDEA-CFB</option>
						<option value="rc2-cfb" >RC2-CFB</option>
						<option value="seed-cfb" >SEED-CFB</option>
						<option value="salsa20" >SALSA20</option>
						<option value="chacha20" >CHACHA20</option>
					</select>
				</div>
			</div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="save_config"><%= ${_LANG_Form_Save} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
var UI = {};
UI.Not_Runed = '<%= ${_LANG_Form_Not_Runed} %>';
UI.Runed = '<%= ${_LANG_Form_Runed} %>';
UI.Edit = '<%= ${_LANG_Form_Edit} %>';
UI.Remove = '<%= ${_LANG_Form_Remove} %>';
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<script src="/apps/shadowsocks/shadowsocks.js"></script>
</body>
</html>
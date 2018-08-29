#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "download_client_json" ] &>/dev/null; then
	eval $(uci show shadowvpn | cut -d '.' -f3-)
	. /lib/functions/network.sh; network_get_ipaddr wanip wan
echo '{}' | jshon -Q -s "${wanip}" -i server -n ${mtu} -i mtu -n ${port} -i port -s "${server_iner_ip}" -i server_iner_ip -s "${net}" -i net -s "${password}" -i password -j | /usr/shellgui/progs/main.sbin http_download shadowvpn-client.json
return
fi
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
<%
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
if [ $(uci get shadowvpn.@shadowvpn[0].enable) -gt 0 ]; then
	if uci get shadowvpn.@shadowvpn[0].mode | grep -q server; then
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
fi
%>
<div class="content">
	<div class="app row app-item">
		<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_ShadowVPN_Status} %></h2>
		<div class="col-sm-offset-1 col-sm-6">
			<div class="table-responsive  text-left">
				<p><%= ${_LANG_Form_Mode} %>: <% eval echo '$_LANG_Form_'${real_at} %></p>
				<p><% pidof shadowvpn &>/dev/null && printf "${_LANG_Form_Running}," || printf "${_LANG_Form_Not_running}";tun_ip=$(shellgui '{"action": "get_ifces_status"}'| jshon -e "ss0" -e "ip" -u); [ -n "${tun_ip}" ] && printf "${_LANG_Form_Connected__IP}: ${tun_ip}" %></p>
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
<% eval $(uci show shadowvpn | cut -d '.' -f3-) %>
<div class="tab-content">
    <div class="tab-pane <%= ${tab_ser_at} %>" id="vpn_server">
        <div class="app row app-item">
            <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Server_setting} %></h2>
            <div class="col-sm-offset-1 col-sm-6">
                <form class="form-horizontal text-left" name="set_shadowvpn_server" id="set_shadowvpn_server">
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Server} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="server" value="<%= ${server} %>" placeholder="0.0.0.0">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Port} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="port" value="<%= ${port} %>" placeholder="1123">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Password} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="password" value="<%= ${password} %>" placeholder="my_password">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Concurrency} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="concurrency" value="<%= ${concurrency} %>" placeholder="1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Internal_IP_Mask} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="net" value="<%= ${net} %>" placeholder="10.7.0.1/24">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">ShadowVPN MTU:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="mtu" value="<%= ${mtu} %>" placeholder="1432">
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
        <div class="app row app-item">
            <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Download_client_Setting} %></h2>
            <div class="col-sm-offset-1 col-sm-6">
				<div class="form-group">
					<label class="col-sm-4 control-label"><%= ${_LANG_Form_Click_to_download} %>:</label>
					<div class="col-sm-8">
						<a href="/?app=shadowvpn&action=download_client_json"><button class="btn btn-default"><%= ${_LANG_Form_Download} %></button></a>
					</div>
				</div>
            </div>
        </div>
    </div>
    <div class="tab-pane <%= ${tab_cli_at} %>" id="vpn_client">
        <div class="app row app-item">
            <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Upload_Client_Configuration_File} %></h2>
            <div class="col-sm-offset-1 col-sm-6">
                <form class="form text-left" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="/apps/shadowvpn/upload.cgi">
                    <div class="form-group upload-ctrl">
                        <label for="upload-cfg" class="">
                            <p class="btn btn-info"><%= ${_LANG_Form_Browse} %></p>
                            <p class="file-name" id="file_name"><%= ${_LANG_Form_Upload_file} %></p>
                        </label>
                        <input type="file" id="upload-cfg" name="file" class="form-control fw-file">
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Upload} %></button>
                    </div>
                </form>
            </div>
        </div>
        <div class="app row app-item">
            <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Client_setting} %></h2>
            <div class="col-sm-offset-1 col-sm-6">
                <form class="form-horizontal text-left" name="set_shadowvpn_client" id="set_shadowvpn_client">
					<div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Server} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="server" value="<%= ${server} %>" placeholder="0.0.0.0">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Port} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="port" value="<%= ${port} %>" placeholder="1123">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Password} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="password" value="<%= ${password} %>" placeholder="my_password">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Concurrency} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="concurrency" value="<%= ${concurrency} %>" placeholder="1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Internal_IP_Mask} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="server_iner_ip" value="<%= ${server_iner_ip} %>" placeholder="10.7.0.1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Internal_LAN_IP} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="server_iner_lanip" value="<%= ${server_iner_lanip} %>" placeholder="192.168.2.1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Internal_LAN_MASK} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="server_iner_lanmask" value="<%= ${server_iner_lanmask} %>" placeholder="225.225.225.0">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_ShadowVPN_Internal_IP_Mask} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="net" value="<%= ${net} %>" placeholder="10.7.0.1/24">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">ShadowVPN MTU:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="mtu" value="<%= ${mtu} %>" placeholder="1432">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label"><%= ${_LANG_Form_Excepted_Countries} %>:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" name="except_cc" value="<%= ${except_cc} %>" placeholder="CN,US">
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
    </div>
    <div class="tab-pane <%= ${tab_dis_at} %>" id="vpn_disabled">
        <div class="app row app-item">
            <form class="form-horizontal text-left" name="disable_shadowvpn" id="disable_shadowvpn">
                <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Disable_ShadowVPN} %></h2>
                <div class="col-sm-offset-1 col-sm-6">
                    <div class="table-responsive">
                        <p><%= ${_LANG_Form_Disable_ShadowVPN} %></p>
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
</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
  (function(){
    $('#upload-cfg').change(function(){
      var file = $(this).val();
      var file_name = file.split('\\').pop();
      $('#file_name').html(file_name);
    });
    $('#set_shadowvpn_server').submit(function(e){
      e.preventDefault();
      var data = "app=shadowvpn&action=set_shadowvpn_server&"+$(this).serialize();
      Ha.disableForm('set_shadowvpn_server');
      Ha.ajax('/','json',data,'post','set_shadowvpn_server',Ha.showNotify,1);
    });
    $('#set_shadowvpn_client').submit(function(e){
      e.preventDefault();
      var data = "app=shadowvpn&action=set_shadowvpn_client&"+$(this).serialize();
      Ha.disableForm('set_shadowvpn_client');
      Ha.ajax('/','json',data,'post','set_shadowvpn_client',Ha.showNotify,1);
    });
    $('#disable_shadowvpn').submit(function(e){
      e.preventDefault();
      var data = "app=shadowvpn&action=disable_shadowvpn";
      Ha.disableForm('disable_shadowvpn');
      Ha.ajax('/','json',data,'post','disable_shadowvpn',Ha.showNotify,1);
    });
  })();
</script>
</body>
</html>
<%
tab_like() { %>
      <div class="col-sm-12">
        <ul class="nav nav-tabs">
          <li class="<% [ "$proto" = "pppoe" ] && printf active %>"><a href="#pppoe_<%= ${wan} %>" data-toggle="tab"><%= ${_LANG_Form_PPPOE} %></a></li>
          <li class="<% [ "$proto" = "dhcp" ] && printf active %>"><a href="#dhcp_<%= ${wan} %>" data-toggle="tab"><%= ${_LANG_Form_DHCP} %></a></li>
          <li class="<% [ "$proto" = "static" ] && printf active %>"><a href="#static_<%= ${wan} %>" data-toggle="tab"><%= ${_LANG_Form_Static} %></a></li>
        </ul>
      </div>
      <div class="tab-content col-md-4">
        <div class="tab-pane <% [ "$proto" = "pppoe" ] && printf active %>" id="pppoe_<%= ${wan} %>">
          <form class="form-horizontal" name='pppoe' id="<%= ${wan} %>_pppoe" disabled>
            <div class="form-group">
              <label for="account" class="col-sm-3 control-label"><%= ${_LANG_Form_Username} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaLength" id="<%= ${wan} %>_pppoe_username" name="username" value="<%= $username %>" placeholder="<%= ${_LANG_Form_Username} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Username} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="password" class="col-sm-3 control-label"><%= ${_LANG_Form_Password} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaLength" name="password" id="<%= ${wan} %>_pppoe_password" value="<%= $password %>" placeholder="<%= ${_LANG_Form_Password} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Password} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="mtu" class="col-sm-3 control-label">MTU</label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-validate="vaInt_1_1500" name="mtu" id="<%= ${wan} %>_pppoe_mtu" value="<%= $mtu %>" placeholder="1500">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> MTU(1-1500)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="metric" class="col-sm-3 control-label"><%= ${_LANG_Form_Metric} %></label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-validate="vaInt_0_255" name="metric" id="<%= ${wan} %>_pppoe_metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns1" id="<%= ${wan} %>_pppoe_dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns2" id="<%= ${wan} %>_pppoe_dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
        </div>
        <div class="tab-pane <% [ "$proto" = "dhcp" ] && printf active %>" id="dhcp_<%= ${wan} %>">
          <form class="form-horizontal" id="<%= ${wan} %>_dhcp" name="dhcp" disabled>
            <div class="form-group">
              <label for="metric" class="col-sm-3 control-label"><%= ${_LANG_Form_Metric} %></label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-validate="vaInt_0_255" name="metric" id="<%= ${wan} %>_dhcp_metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns1" id="<%= ${wan} %>_dhcp_dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns2" id="<%= ${wan} %>_dhcp_dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
        </div>
        <div class="tab-pane <% [ "$proto" = "static" ] && printf active %>" id="static_<%= ${wan} %>">
          <form class="form-horizontal" id="<%= ${wan} %>_static" name="static" disabled>
            <div class="form-group">
              <label for="ipadr" class="col-sm-3 control-label"><%= ${_LANG_Form_IP_Address} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP-vaLength" name="ipaddr" id="<%= ${wan} %>_static_ipaddr" placeholder="<%= ${_LANG_Form_IP_Address} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="netmask" class="col-sm-3 control-label"><%= ${_LANG_Form_Netmask} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP-vaLength" name="netmask" id="<%= ${wan} %>_static_netmask" placeholder="<%= ${_LANG_Form_Netmask} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Netmask} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="gate" class="col-sm-3 control-label"><%= ${_LANG_Form_Gateway} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP-vaLength" name="gateway" id="<%= ${wan} %>_static_gateway" placeholder="<%= ${_LANG_Form_Gateway} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Gateway} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="metric" class="col-sm-3 control-label"><%= ${_LANG_Form_Metric} %></label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-validate="vaInt_0_255" name="metric" id="<%= ${wan} %>_static_metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns1" id="<%= ${wan} %>_static_dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns2" id="<%= ${wan} %>_static_dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div class="col-sm-12 adv_btn" style="cursor: pointer;" data-for="<%= ${wan} %>_adv_setting">
        <h4><small><span class="icon-plus"></span></small><%= ${_LANG_Form_Adventure} %>(<%= ${wan} %>)</h4>
      </div>
      <div id="<%= ${wan} %>_adv_setting" class="hidden">
		<% if [ $is_vwan -eq 0 ]; then %>
        <div class="col-sm-12">
          <h4><%= ${_LANG_Form_Clone_Nic} %></h4>
        </div>
        <div class="col-sm-offset-1 col-sm-11">
          <div class="form-group">
            <div class="switch-ctrl switch-sm" id="<%= ${wan} %>_clone" style="margin-bottom: -5px">
              <input type="checkbox" id="switch_<%= ${wan} %>_clone" checked>
              <label for="switch_<%= ${wan} %>_clone"><span></span></label>
            </div>    
            <label><%= ${_LANG_Form_Copy_proto_and_configuration} %></label>
          </div>
          <button type="submit" class="btn btn-default submit_clone" data-wan="<%= ${wan} %>" disabled><%= ${_LANG_Form_Clone} %></button>
        </div>
		<% fi %>

        <div class="col-sm-12">
          <h4><%= ${_LANG_Form_Mac} %></h4>
        </div>
        <div class="col-sm-offset-1 col-sm-11">
          <form class="form-inline">
            <div class="form-group">
      				<input type="text" class="form-control" data-validate="vaMac-vaLength" id="macaddr_<%= ${wan} %>" value="<%= ${macaddr} %>" placeholder="xx:xx:xx:xx:xx:xx">
      				<button type="submit" class="btn btn-default submit_mac" data-wan="<%= ${wan} %>" disabled><%= ${_LANG_Form_Apply} %></button>
      				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Mac} %></span>
            </div>
          </form>
        </div>

        <div class="col-sm-12">
          <h4><%= ${_LANG_Form_Keep_IP_in_range} %></h4>
        </div>
        <form class="col-sm-offset-1 col-sm-11 col-md-3 ip_limit_container" data-wan="<%= ${wan} %>" id="ip_limit_container_<%= ${wan} %>">
          <div class="form-group">
						<div class="switch-ctrl switch-sm ip_limit_enable_switch" style="margin-bottom: -5px">
						  <input type="checkbox" name="ip_limit_enable" id="<%= ${wan} %>_ip_limit_enable" <% [ ${ip_limit_enable} -gt 0 ] && printf 'checked' %>>
						  <label for="<%= ${wan} %>_ip_limit_enable"><span></span></label>
						</div>    
						<label><%= ${_LANG_Form_Enabled} %></label>
          </div>
          <div class="form-group">
						<label><%= ${_LANG_Form_IP_range} %></label>
						<input type="text" class="form-control" data-validate="vaIPRanges-vaLength" name="ip_limit_range" id="<%= ${wan} %>_ip_limit_range" data-wan="<%= ${wan} %>" value="<%= ${ip_limit_range} %>" placeholder="1.1.1.1-1.1.1.5,2.2.2.1-2.2.2.5">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %>:IP-IP,IP-IP<br/><%= ${_LANG_Form_IF_nat_IP} %></span>
          </div>
          <div class="form-group">
						<label><%= ${_LANG_Form_Maximum_daily_check} %></label>
						<div class="input-group">
							<input type="number" class="form-control" data-validate="vaInt-vaLength" name="ip_limit_times" id="<%= ${wan} %>_ip_limit_times" data-wan="<%= ${wan} %>" placeholder="1" value=<%= ${ip_limit_times} %>>
						<span class="input-group-addon"><%= ${_LANG_Form_Times} %></span>
						</div>
          </div>

          <div class="form-group">
						<div class="switch-ctrl switch-sm" style="margin-bottom: -5px">
						  <input type="checkbox" name="ip_limit_reverse" id="<%= ${wan} %>_ip_limit_reverse" <% [ ${ip_limit_reverse} -gt 0 ] && printf 'checked' %>>
						  <label for="<%= ${wan} %>_ip_limit_reverse"><span></span></label>
						</div>    
						<label><%= ${_LANG_Form_Reverse_condition} %></label>
          </div>
					<button type="submit" class="btn btn-default" id="submit_ip_limit_<%= ${wan} %>" disabled><%= ${_LANG_Form_Apply} %></button>
        </form>

      </div>
<% }
m_3g_like() { %>
      <div class="tab-content col-md-4">
          <form class="form-horizontal" name='3g' id="<%= ${wan} %>_3g" disabled>
            <div class="form-group">
              <label for="account" class="col-sm-3 control-label">协议</label>
              <div class="col-sm-9">
				<fieldset disabled><input class="form-control" value="UMTS/GPRS/CDMA/EV-DO" /></fieldset>
              </div>
            </div>
            <div class="form-group">
              <label for="account" class="col-sm-3 control-label">调试解调器节点</label>
              <div class="col-sm-9">
				<select name="device" class="form-control">
					<% for dev in $(ls /dev/tty[A-Z]* /dev/tts/*); do
					%><option value="<%= ${dev} %>" <% [ "${device}" = "${dev}" ] && printf 'selected' %>><%= ${dev} %></option><%
					done %>
				</select>
              </div>
            </div>
            <div class="form-group">
              <label for="account" class="col-sm-3 control-label">服务类型</label>
              <div class="col-sm-9">
				<select name="service" class="form-control">
					<option value="umts" <% [ "${service}" = "umts" ] && printf 'selected' %>>UMTS/GPRS</option>
					<option value="umts_only" <% [ "${service}" = "umts_only" ] && printf 'selected' %>>UMTS only</option>
					<option value="gprs_only" <% [ "${service}" = "gprs_only" ] && printf 'selected' %>>GPRS only</option>
					<option value="evdo" <% [ "${service}" = "evdo" ] && printf 'selected' %>>CDMA/EV-DO</option>
				</select>
              </div>
            </div>
            <div class="form-group">
              <label for="apn" class="col-sm-3 control-label">APN</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaLength" name="apn" id="<%= ${wan} %>_3g_apn" value="<%= $apn %>" placeholder="ctnet">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> APN</span>
              </div>
            </div>
            <div class="form-group">
              <label for="pincode" class="col-sm-3 control-label">PIN</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control"  name="pincode" id="<%= ${wan} %>_3g_pincode" value="<%= $pincode %>" placeholder="ctnet">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> PIN</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dialnumber" class="col-sm-3 control-label">拨号号码</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaLength" name="dialnumber" id="<%= ${wan} %>_3g_dialnumber" value="<%= $dialnumber %>" placeholder="*99#">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> 拨号号码</span>
              </div>
            </div>
            <div class="form-group">
              <label for="account" class="col-sm-3 control-label"><%= ${_LANG_Form_Username} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" id="<%= ${wan} %>_3g_username" name="username" value="<%= $username %>" placeholder="<%= ${_LANG_Form_Username} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Username} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="password" class="col-sm-3 control-label"><%= ${_LANG_Form_Password} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="password" id="<%= ${wan} %>_3g_password" value="<%= $password %>" placeholder="<%= ${_LANG_Form_Password} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Password} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="mtu" class="col-sm-3 control-label">MTU</label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-validate="vaInt_1_1500" name="mtu" id="<%= ${wan} %>_3g_mtu" value="<%= $mtu %>" placeholder="1500">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> MTU(1-1500)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="metric" class="col-sm-3 control-label"><%= ${_LANG_Form_Metric} %></label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-validate="vaInt_0_255" name="metric" id="<%= ${wan} %>_3g_metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns1" id="<%= ${wan} %>_3g_dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-validate="vaIP" name="dns2" id="<%= ${wan} %>_3g_dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
      </div>




      <div class="col-sm-12 adv_btn" style="cursor: pointer;" data-for="<%= ${wan} %>_adv_setting">
        <h4><small><span class="icon-plus"></span></small><%= ${_LANG_Form_Adventure} %>(<%= ${wan} %>)</h4>
      </div>
      <div id="<%= ${wan} %>_adv_setting" class="hidden">
        <div class="col-sm-12">
          <h4><%= ${_LANG_Form_Mac} %></h4>
        </div>
        <div class="col-sm-offset-1 col-sm-11">
          <form class="form-inline">
            <div class="form-group">
      				<input type="text" class="form-control" data-validate="vaMac-vaLength" id="macaddr_<%= ${wan} %>" value="<%= ${macaddr} %>" placeholder="xx:xx:xx:xx:xx:xx">
      				<button type="submit" class="btn btn-default submit_mac" data-wan="<%= ${wan} %>" disabled><%= ${_LANG_Form_Apply} %></button>
      				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Mac} %></span>
            </div>
          </form>
        </div>

        <div class="col-sm-12">
          <h4><%= ${_LANG_Form_Keep_IP_in_range} %></h4>
        </div>
        <form class="col-sm-offset-1 col-sm-11 col-md-3 ip_limit_container" data-wan="<%= ${wan} %>" id="ip_limit_container_<%= ${wan} %>">
          <div class="form-group">
						<div class="switch-ctrl switch-sm ip_limit_enable_switch" style="margin-bottom: -5px">
						  <input type="checkbox" name="ip_limit_enable" id="<%= ${wan} %>_ip_limit_enable" <% [ ${ip_limit_enable} -gt 0 ] && printf 'checked' %>>
						  <label for="<%= ${wan} %>_ip_limit_enable"><span></span></label>
						</div>    
						<label><%= ${_LANG_Form_Enabled} %></label>
          </div>
          <div class="form-group">
						<label><%= ${_LANG_Form_IP_range} %></label>
						<input type="text" class="form-control" data-validate="vaIPRanges-vaLength" name="ip_limit_range" id="<%= ${wan} %>_ip_limit_range" data-wan="<%= ${wan} %>" value="<%= ${ip_limit_range} %>" placeholder="1.1.1.1-1.1.1.5,2.2.2.1-2.2.2.5">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %>:IP-IP,IP-IP<br/><%= ${_LANG_Form_IF_nat_IP} %></span>
          </div>
          <div class="form-group">
						<label><%= ${_LANG_Form_Maximum_daily_check} %></label>
						<div class="input-group">
							<input type="number" class="form-control" data-validate="vaInt-vaLength" name="ip_limit_times" id="<%= ${wan} %>_ip_limit_times" data-wan="<%= ${wan} %>" placeholder="1" value=<%= ${ip_limit_times} %>>
						<span class="input-group-addon"><%= ${_LANG_Form_Times} %></span>
						</div>
          </div>

          <div class="form-group">
						<div class="switch-ctrl switch-sm" style="margin-bottom: -5px">
						  <input type="checkbox" name="ip_limit_reverse" id="<%= ${wan} %>_ip_limit_reverse" <% [ ${ip_limit_reverse} -gt 0 ] && printf 'checked' %>>
						  <label for="<%= ${wan} %>_ip_limit_reverse"><span></span></label>
						</div>    
						<label><%= ${_LANG_Form_Reverse_condition} %></label>
          </div>
					<button type="submit" class="btn btn-default" id="submit_ip_limit_<%= ${wan} %>" disabled><%= ${_LANG_Form_Apply} %></button>
        </form>

      </div>
<% }
%>

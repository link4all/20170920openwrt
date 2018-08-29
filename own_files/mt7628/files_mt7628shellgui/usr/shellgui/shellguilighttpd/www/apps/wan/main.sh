#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_|_LANG_App_' ${FORM_app} $COOKIE_lang)
env >/tmp/1
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "wan"}' %>
</div>
<div id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name}")" %>"><span class="glyphicon glyphicon-link"></span></a></div>
</div>
<div class="container">
	<div class="header row">
		<h1><%= ${_LANG_Form_Adventure} %></h1>
	</div>
	<div class="form-group">
		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_syncppp} %></label>
		<div class="col-sm-8">
		  <div class="switch-ctrl head-switch" id="switch_syncppp" data-toggle="modal" data-target="#confirmModal">
			  <input type="checkbox" name="nic-switch" id="switch_syncppp_in" value="" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/wan/mpppoe ] && printf 'checked'%>>
			  <label for="switch_syncppp_in"><span></span></label>
		  </div>
		</div>
	</div>
</div>

<%
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
type=;ifname=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans ${ifce}"
done
for wan in $wans; do
proto=;dns=;mtu=;macaddr=;_Global_HW_mode=;_Global_SW_mode=
type=;ip6assign=;ipaddr=;netmask=;metric=
dhcp=
username=;password=
pre_exec=$(echo "$network_str" | grep 'network\.'${wan}'\.' | cut -d '.' -f3-)
echo "$pre_exec" | grep -qE "[\']$" || echo "$pre_exec" | grep -qE "[\"]$"
if [ $? -eq 0 ]; then
eval $pre_exec
else
eval $(echo "$pre_exec" | sed -e 's#=#=\"#g' -e 's#$#\"#g')
fi
dns1=$(echo "$dns" | awk '{print $1}')
dns2=$(echo "$dns" | awk '{print $2}')
echo "${wan}" | grep -qE '^v[a-z0-9]*_[0-9]*' && is_vwan=1 || is_vwan=0
%>
  <div class="container" id="<%= ${wan} %>_container">
    <div class="header row">
      <h1><%= ${_LANG_Form_Wan_Setting} %>(<%= ${wan} %><%
	  if [ -n "${_Global_HW_mode}" ]; then
	  printf "|${_LANG_Form_Global_HW_mode}:"
	  jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_HW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u
	  fi
	  if [ -n "${_Global_SW_mode}" ]; then
	  printf "|${_LANG_Form_Global_SW_mode}:"
	  jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u
	  fi
	  %>)</h1>
	  <% if [ $is_vwan -gt 0 ]; then %><span class="glyphicon glyphicon-remove text-danger remove_vwan_btn" id="remove_btn_<%= ${wan} %>" data-toggle="modal" data-target="#confirmModal"></span> <% fi %>
      <span id="wanType_<%= ${wan} %>"><%= ${_LANG_Form_Watting_for_connection_check} %>...</span>
    </div>
    <div class="hidden" id="<%= ${wan} %>_info">
      <table class="table table-hover">
        <tr>
          <th><%= ${_LANG_Form_IP_Address} %></th>
          <td id="<%= ${wan} %>_info_ip"></td>
        </tr>
        <tr>
          <th><%= ${_LANG_Form_Netmask} %></th>
          <td id="<%= ${wan} %>_info_mask"></td>
        </tr>
        <tr>
          <th><%= ${_LANG_Form_Gateway} %></th>
          <td id="<%= ${wan} %>_info_gateway"></td>
        </tr>
        <tr>
          <th>DNS</th>
          <td id="<%= ${wan} %>_info_dns"></td>
        </tr>
        <tr>
          <td colspan='2'>
            <button class="btn btn-default btn-sm show-set-btn" id="<%= ${wan} %>_set_btn"><%= ${_LANG_Form_Set_Wan} %></button>
          </td>
        </tr>
      </table>
    </div>
    <div class="content row status-block" id="wanSet_<%= ${wan} %>">
<% if [ "$proto" != "none" ] || ifconfig ${ifname} &>/dev/null; then %>
      
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
                <input type="text" disabled class="form-control" data-type="required" name="username" value="<%= $username %>" placeholder="<%= ${_LANG_Form_Username} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Username} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="password" class="col-sm-3 control-label"><%= ${_LANG_Form_Password} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="required" name="password" value="<%= $password %>" placeholder="<%= ${_LANG_Form_Password} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Password} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="mtu" class="col-sm-3 control-label">MTU</label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-type="number" name="mtu" value="<%= $mtu %>" placeholder="1500">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> MTU(1-1500)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="metric" class="col-sm-3 control-label"><%= ${_LANG_Form_Metric} %></label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-type="metric" name="metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="ip" name="dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="ip" name="dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
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
                <input type="number" disabled class="form-control" data-type="metric" name="metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="ip" name="dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="ip" name="dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
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
                <input type="text" disabled class="form-control" data-type="requiredip" name="ipaddr" placeholder="<%= ${_LANG_Form_IP_Address} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="netmask" class="col-sm-3 control-label"><%= ${_LANG_Form_Netmask} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="requiredip" name="netmask" placeholder="<%= ${_LANG_Form_Netmask} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Netmask} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="gate" class="col-sm-3 control-label"><%= ${_LANG_Form_Gateway} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="requiredip" name="gateway" placeholder="<%= ${_LANG_Form_Gateway} %>">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Gateway} %></span>
              </div>
            </div>
            <div class="form-group">
              <label for="metric" class="col-sm-3 control-label"><%= ${_LANG_Form_Metric} %></label>
              <div class="col-sm-9">
                <input type="number" disabled class="form-control" data-type="number" name="metric" value="<%= $metric %>" placeholder="0">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> <%= ${_LANG_Form_Metric} %>(0-255)</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="ip" name="dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> DNS</span>
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" data-type="ip" name="dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
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
        <h4><small><span class="glyphicon glyphicon-plus"></span></small><%= ${_LANG_Form_Adventure} %>(<%= ${wan} %>)</h4>
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
          <div class="form-inline">
				<input type="text" class="form-control mac_input" id="macaddr_<%= ${wan} %>" value="<%= ${macaddr} %>" placeholder="xx:xx:xx:xx:xx:xx">
				<button type="submit" class="btn btn-default submit_mac" data-wan="<%= ${wan} %>" disabled><%= ${_LANG_Form_Apply} %></button>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Mac} %></span>
          </div>
        </div>

        <div class="col-sm-12">
          <h4>确保IP范围</h4>
        </div>
        <div class="col-sm-offset-1 col-sm-11 col-md-3">
          <div class="form-group">
				<div class="switch-ctrl switch-sm" id="<%= ${wan} %>_ip_limit_enable" style="margin-bottom: -5px">
				  <input type="checkbox" id="switch_ip_limit_<%= ${wan} %>_ip_limit_enable">
				  <label for="switch_ip_limit_<%= ${wan} %>_ip_limit_enable"><span></span></label>
				</div>    
				<label>启用</label>
          </div>
          <div class="form-group">
				<label>获取的IP允许范围</label>
				<input type="text" class="form-control mac_input" id="ip_limit_range_<%= ${wan} %>" value="<%= ${macaddr} %>" placeholder="1.1.1.1-1.1.1.5,2.2.2.1-2.2.2.5">
				<span class="help-block hidden">格式：IP-IP,IP-IP</span>
          </div>
          <div class="form-group">
				<label>每日检查次数上限</label>
				<input type="number" class="form-control mac_input" id="ip_limit_times_<%= ${wan} %>" value=1 placeholder="1">
				<span class="help-block hidden">格式：IP-IP,IP-IP</span>
          </div>
          <div class="form-group">
				<div class="switch-ctrl switch-sm" id="<%= ${wan} %>_ip_limit_reverse" style="margin-bottom: -5px">
				  <input type="checkbox" id="switch_ip_limit_<%= ${wan} %>_ip_limit_reverse">
				  <label for="switch_ip_limit_<%= ${wan} %>_ip_limit_reverse"><span></span></label>
				</div>    
				<label>反向判断</label>
          </div>
				<button type="submit" class="btn btn-default submit_mac" data-wan="<%= ${wan} %>" disabled>应用</button>
        </div>

      </div>
<% fi %>
    </div>
  </div>
<% done %>
</div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">title</h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text">text</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f%>
<% /usr/shellgui/progs/main.sbin h_end '{"js":["/apps/wan/wan.js"]}'
%>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
$('#switch_syncppp').click(function() {
	var checked = $(this).find('[type="checkbox"]').prop('checked');
	var text = checked ? '<%= ${_LANG_Form_syncppp} ${_LANG_Form_Enabled} %>?' : '<%= ${_LANG_Form_syncppp} ${_LANG_Form_Enabled} %>?';
	Ha.alterModal('confirmModal','<%= ${_LANG_Form_syncppp} %>',text,submitsyncppp,'switch_syncppp');
});
function submitsyncppp(switchId){
  	var status = $('#' + switchId).find('[type="checkbox"]').prop('checked');
  	var enable = status ? 0 : 1;
  	var post_data = 'app=wan&action=enable_syncppp&enabled=' + enable;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
	  	var result = data.status == 1 ? false : true;
	  	var checked = status;
	  	Ha.setSwitchBtn(switchId,result,checked);
	  	console.log($('#' + switchId).find('[type="checkbox"]').prop('checked'));
	},'json');
}
</script>
</body>
</html>
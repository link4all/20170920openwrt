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
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
. /usr/shellgui/shellguilighttpd/www/apps/vlan/lib.sh
network_str=$(uci show -X network)
vlan_dev_configs=$(echo "$network_str" | grep -E '=switch$' | grep -Eo 'cfg[0-9a-z]*')
switch_vlan_configs=$(echo "$network_str" | grep -E '=switch_vlan$' | grep -Eo 'cfg[0-9a-z]*')
%>
<script>
	var switchs = {};
	<% for vlan_dev_config in ${vlan_dev_configs}; do switch=$(uci get network.${vlan_dev_config}.name); get_vlan_info ${switch} %>
	<% for switch_vlan_config in $switch_vlan_configs; do
	if uci get network.${switch_vlan_config}.device | grep -qE "^${switch}$"; then %>
		switchs["<%= ${switch} %>"] = {};
		switchs["<%= ${switch} %>"].vlans = [];
		var vlan = {};
		vlan.vlan_id = <%= $(uci get network.${switch_vlan_config}.vlan) %>;
		vlan.ports = "<%= $(uci get network.${switch_vlan_config}.ports) %>";
		vlan.config = "<%= ${switch_vlan_config} %>";
		switchs["<%= ${switch} %>"].vlans.push(vlan);
	<% fi
	done %>
	switchs["<%= ${switch} %>"].portsCount = <%= ${vlan_ports} %>;
	switchs["<%= ${switch} %>"].cpuPort = <%= ${cpu_port} %>;
	switchs["<%= ${switch} %>"].support_vlans = <%= ${support_vlans} %>;
	switchs["<%= ${switch} %>"].dev_desc = '<%= ${switch_dev_desc} %>';
</script>
		<div class="app row app-item switch_item" id="switch_<%= ${switch} %>">
			<h2 class="app-sub-title col-sm-12"><%= ${switch_dev_desc} %></h2>
			<div class="col-sm-12 table-responsive">
				<table class="table">
					<thead>
						<tr id="port_tr_<%= ${switch} %>"></tr>
						<tr id="ports_status_tr_<%= ${switch} %>"></tr>
					</thead>
					<tbody id="vlan_trs_<%= ${switch} %>"></tbody>
					<tfoot>
						<tr>
							<td id="add_btn_td_<%= ${switch} %>" class="text-left" colspan="5">
								<span class="help-block text-center hidden id-help" style="color: red">请输入与已有id不重复的正整数，否则将使用系统自动生成的id</span>
								<span class="help-block text-center hidden port-help" style="color: red">不能将所有端口都关闭</span>
								<button id="add_btn_<%= ${switch} %>" class="btn btn-sm btn-success">Add</button>
							</td>
						</tr>
					</tfoot>
				</table>
			</div>
		</div>
<% done %>
		<hr>
		<div class="app row app-item pull-right">
			<button class="btn btn-default btn-lg" id="submit_page_btn">应用</button>
			<button class="btn btn-warning btn-lg" id="reset_page_btn">重置</button>
		</div>
	</div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/vlan/vlan.js"></script>
</body>
</html>
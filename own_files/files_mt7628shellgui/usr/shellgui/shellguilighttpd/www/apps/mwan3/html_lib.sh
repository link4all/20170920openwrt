<% index() { %>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Global_Settings} %></h2>
	<div class="col-sm-offset-2 col-sm-6 text-left">
			<div class="form-group">
				<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Enable_Mwan3} %></label>
				<div class="col-sm-8">
				  <div class="switch-ctrl head-switch" id="switch_mwan_radio0" data-toggle="modal" data-target="#confirmModal">
					  <input type="checkbox" name="nic-switch" id="switch_mwan" value="" <% [ $(uci get mwan3.default.enabled) -gt 0 ] && printf 'checked'%>>
					  <label for="switch_mwan"><span></span></label>
				  </div>
				</div>
			</div>
	</div>
</div>

<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Interfaces_List} %></h2>
	<div class="col-sm-12 text-left">
		<div class="table-responsive">
			<table class="table" id="wan_table">
				<thead>
					<tr>
						<th><%= ${_LANG_Form_Interfaces} %></th>
						<th><%= ${_LANG_Form_Metric} %></th>
						<th><%= ${_LANG_Form_Tracking_IP} %></th>
						<th colspan="2"><%= ${_LANG_Form_Ping_Test} %></th>
						<th><%= ${_LANG_Form_Status} %></th>
						<th><%= ${_LANG_Form_Opt} %></th>
					</tr>
				</thead>
				<tbody>
<%
interfaces_status=$(/usr/shellgui/progs/mwan3 interfaces)
mwan3_wans=$(echo "$mwan3_str" | grep '=interface' | cut -d '=' -f1 | cut -d '.' -f2)
wans_pre_use="$wans"
for wan in $mwan3_wans; do
wans_pre_use=$(echo "$wans_pre_use" | grep -vE "^${wan}$")
enabled=;track_ip=;reliability=;count=;timeout=;interval=;down=;up=
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${wan}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
%>
					<tr id="wan_list_<%= ${wan} %>">
						<td><%= ${wan} %><% if ! echo "$wans" | grep -qE "^${wan}$"; then %>(<%= ${_LANG_Form_Non_existent} %>)<% fi %>
							<span class="help-block"><% echo "$interfaces_status" | grep -E '^ interface '"${wan}"' ' | cut -d ' ' -f4- %></span>
						</td>
						<td class="form-inline">
							<input type="number" min="1" data-validate="num" class="form-control input-sm" value=<% uci get network.${wan}.metric %>>
							<button class="btn btn-sm btn-default metric_btn" id="submit_<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
							<span class="help-block hidden" style="color: red;"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Metric} %>(0-255)</span>
						</td>
						<td>
							<%= ${track_ip// /<br>} %>
						</td>
						<td>
							<%= ${_LANG_Form_Ping_frequency} %>: <%= ${count} %><br>
							<%= ${_LANG_Form_Ping_timeout} %>: <%= ${timeout} %>s<br>
							<%= ${_LANG_Form_Ping_test_interval} %>: <%= ${interval} %>s
						</td>
						<td>
							<%= ${_LANG_Form_Ping_at_least_successful_times} %>: <%= ${reliability} %><br>
							<%= ${_LANG_Form_To_judge_the_lost_connection_times} %>: <%= ${down} %><br>
							<%= ${_LANG_Form_To_judge_the_restore_connection_times} %>: <%= ${up} %>
						</td>
						<td>
							<div class="switch-ctrl switch-sm" id="switch_<%= ${wan} %>_radio0" data-switch="wan" data-toggle="modal" data-target="#confirmModal">
								<input type="checkbox" name="nic-switch" id="switch_<%= ${wan} %>" value="" <% [ ${enabled:-0} -gt 0 ] && printf 'checked'%>>
								<label for="switch_<%= ${wan} %>"><span></span></label>
							</div>
						</td>
						<td>
							<a href="/?app=mwan3&amp;action=edit_wan&wan=<%= ${wan} %>"><button class="btn btn-sm btn-primary"><%= ${_LANG_Form_Edit} %></button></a>
							<button class="btn btn-sm btn-danger" data-wan="<%= ${wan} %>" data-switch="remove-wan" data-toggle="modal" data-target="#confirmModal"><%= ${_LANG_Form_Remove} %></button>
						</td>
					</tr>
<% done %>
				</tbody>
				<tfoot>
					<tr>
						<td colspan="8" class="form-inline">
<% if echo "$wans_pre_use" | grep -qE '[a-z]'; then %>
						<form method="get">
							<input type="hidden" name="app" value="mwan3" />
							<input type="hidden" name="action" value="edit_wan" />
							<select name="wan" class="form-control">
<% for wan in $wans_pre_use; do %>
								<option value="<%= ${wan} %>" <% [ "${interface}" = "${wan}" ] && printf 'selected' %>><%= ${wan} %></option>
<% done %>
							</select>
							<button type="submit" class="btn btn-success"><%= ${_LANG_Form_Add_new} %></button>
						</form>
<% else %>
				<p>没有其它可用的wan</p>
<% fi %>
						</td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>

<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Members_List} %></h2>
	<div class="col-sm-12 text-left">
		<div class="table-responsive">
			<table class="table">
				<thead>
					<tr>
						<th><%= ${_LANG_Form_Member} %></th>
						<th><%= ${_LANG_Form_Interfaces} %></th>
						<th><%= ${_LANG_Form_Metric} %></th>
						<th><%= ${_LANG_Form_Weight} %></th>
						<th><%= ${_LANG_Form_Opt} %></th>
					</tr>
				</thead>
				<tbody>
<%
members=$(echo "$mwan3_str" | grep '=member' | cut -d '=' -f1 | cut -d '.' -f2)
for member in $members; do
interface=;metric=;weight=
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${member}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
%>
				<tr id="member_list_<%= ${member} %>">
					<td>
						<%= ${member} %>
					</td>
					<td>
						<%= ${interface} %>
					</td>
					<td>
						<%= ${metric} %>
					</td>
					<td>
						<%= ${weight} %>
					</td>
					<td>
						<a href="/?app=mwan3&amp;action=edit_member&member=<%= ${member} %>"><button class="btn btn-sm btn-primary"><%= ${_LANG_Form_Edit} %></button></a>
						<button class="btn btn-sm btn-danger" data-member="<%= ${member} %>" data-switch="remove-member" data-toggle="modal" data-target="#confirmModal"><%= ${_LANG_Form_Remove} %></button>
					</td>
				</tr>
<% done %>
				</tbody>
				<tfoot>
					<tr>
						<td colspan="8" class="form-inline">
						<form method="get">
							<input type="hidden" name="app" value="mwan3" />
							<input type="hidden" name="action" value="edit_member" />
							<input name="member" type="text" class="form-control">
							<button class="btn btn-success"><%= ${_LANG_Form_Add_new} %></button>
						</form>
						</td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>

<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Policies_list} %></h2>
	<div class="col-sm-12 text-left">
		<div class="table-responsive">
			<table class="table">
				<thead>
					<tr>
						<th><%= ${_LANG_Form_Policy} %></th>
						<th><%= ${_LANG_Form_Member_in_Policy} %></th>
						<th><%= ${_LANG_Form_Member_of_last_resort} %></th>
						<th><%= ${_LANG_Form_Opt} %></th>
					</tr>
				</thead>
				<tbody>
<%
policys=$(echo "$mwan3_str" | grep '=policy' | cut -d '=' -f1 | cut -d '.' -f2)
for policy in $policys; do
# last_resort=: unreachable(拒绝此类型流量) blackhole(丢弃此类型流量) default(使用系统默认路由表)
use_member=;last_resort=
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${policy}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
%>
				<tr id="policy_list_<%= ${policy} %>">
					<td>
						<%= ${policy} %>
					</td>
					<td>
						<%= ${use_member// /<br>} %>
					</td>
					<td>
						<%= ${last_resort:---} %>
					</td>
					<td>
						<a href="/?app=mwan3&amp;action=edit_policy&policy=<%= ${policy} %>"><button class="btn btn-sm btn-primary"><%= ${_LANG_Form_Edit} %></button></a>
						<button class="btn btn-sm btn-danger" data-policy="<%= ${policy} %>" data-switch="remove-policy" data-toggle="modal" data-target="#confirmModal"><%= ${_LANG_Form_Remove} %></button>
					</td>
				</tr>
<% done %>
				</tbody>
				<tfoot>
					<tr>
						<td colspan="8" class="form-inline">
						<form method="get">
							<input type="hidden" name="app" value="mwan3" />
							<input type="hidden" name="action" value="edit_policy" />
							<input name="policy" type="text" class="form-control">
							<button class="btn btn-success"><%= ${_LANG_Form_Add_new} %></button>
						</form>
						</td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>

<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Rules_List} %></h2>
	<div class="col-sm-12 text-left">
		<div class="table-responsive">
			<table class="table">
				<thead>
					<tr>
						<th><%= ${_LANG_Form_Rule} %></th>
						<th colspan="2"><%= ${_LANG_Form_Setting} %></th>
						<th><%= ${_LANG_Form_Use_Policy} %></th>
						<th><%= ${_LANG_Form_Opt} %></th>
					</tr>
				</thead>
				<tbody>
<%
rules=$(echo "$mwan3_str" | grep '=rule' | cut -d '=' -f1 | cut -d '.' -f2)
for rule in $rules; do
src_ip=;src_port=;dest_ip=;dest_port=;proto=;sticky=;timeout=;ipset=;use_policy=
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${rule}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
%>
				<tr id="rule_list_<%= ${rule} %>">
					<td>
						<%= ${rule} %>
					</td>
					<td>
						<%= ${_LANG_Form_Source_addr} %>:<%= ${src_ip:---} %><br>
						<%= ${_LANG_Form_Source_port} %>:<%= ${src_port:---} %><br>
						<%= ${_LANG_Form_Dest_addr} %>:<%= ${dest_ip:---} %><br>
						<%= ${_LANG_Form_Dest_port} %>:<%= ${dest_port:---} %><br>
					</td>
					<td>
						<%= ${_LANG_Form_Proto} %>:<%= ${proto:---} %><br>
						<%= ${_LANG_Form_Sticky} %>:<% [ ${sticky} -gt 0 ] && printf ${_LANG_Form_On} || printf ${_LANG_Form_Off} %><br>
						<%= ${_LANG_Form_Sticky_timeout} %>:<%= ${timeout:---} %>s<br>
						<%= ${_LANG_Form_IPset_chain} %>:<%= ${ipset:---} %>
					</td>
					<td>
						<% if echo ${use_policy} | grep -qE 'unreachable|blackhole|default'; then eval echo '$_LANG_Form_'${use_policy}; else echo ${use_policy};fi %>
					</td>
					<td>
						<a href="/?app=mwan3&amp;action=edit_rule&rule=<%= ${rule} %>"><button class="btn btn-sm btn-primary"><%= ${_LANG_Form_Edit} %></button></a>
						<button class="btn btn-sm btn-danger"  data-rule="<%= ${rule} %>" data-switch="remove-rule" data-toggle="modal" data-target="#confirmModal"><%= ${_LANG_Form_Remove} %></button>
					</td>
				</tr>

<% done %>
				</tbody>
				<tfoot>
					<tr>
						<td colspan="8" class="form-inline">
						<form method="get">
							<input type="hidden" name="app" value="mwan3" />
							<input type="hidden" name="action" value="edit_rule" />
							<input name="rule" type="text" class="form-control">
							<button class="btn btn-success"><%= ${_LANG_Form_Add_new} %></button>
						</form>
						</td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>
<%
}
edit_wan() {
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${FORM_wan}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
%>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Mwan3_Interfaces_Edit} %>- <%= $FORM_wan %></h2>
<div class="col-sm-offset-2 col-sm-6 text-left">
	<form class="form-horizontal text-left" id="set_wan">
	<fieldset>
		<input type="hidden" name="wan" value="<%= ${FORM_wan} %>" />
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Tracking_IP} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control" name="track_ip" required data-validate="ip" value="<%= $(echo "$track_ip" | sed 's#[ ][ ]*#,#g') %>">
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_addr}","${_LANG_Form_Allow_multi_IPS__Comma_separated} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Ping_frequency} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${count} %> name="count">
				  <span class="input-group-addon">次</span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Ping_timeout} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${timeout} %> name="timeout">
				  <span class="input-group-addon"><%= ${_LANG_Form_Secs} %></span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
		<label class="col-sm-4 control-label"><%= ${_LANG_Form_Ping_test_interval} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${interval} %> name="interval">
				  <span class="input-group-addon"><%= ${_LANG_Form_Secs} %></span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Ping_at_least_successful_times} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${reliability} %> name="reliability">
				  <span class="input-group-addon"><%= ${_LANG_Form_Secs} %></span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_To_judge_the_lost_connection_times} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${down} %> name="down">
				  <span class="input-group-addon">次</span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_To_judge_the_restore_connection_times} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${up} %> name="up">
				  <span class="input-group-addon">次</span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-offset-4 col-sm-8">
				<button type="submit" id="submit_wan_btn" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
			</div>
		</div>
	</fieldset>
	</form>
</div>
</div> 
<%
}
edit_member() {
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${FORM_member}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
%>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Mwan3_Member_Edit} %>- <%= ${FORM_member} %></h2>
<div class="col-sm-offset-2 col-sm-6 text-left">
	<form class="form-horizontal text-left" id="set_member">
	<fieldset>
		<input type="hidden" name="member" value="<%= ${FORM_member} %>" />
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Interfaces} %></label>
			<div class="col-sm-8">
				<select name="wan" class="form-control">
<% for wan in $wans; do %>
					<option value="<%= ${wan} %>" <% [ "${interface}" = "${wan}" ] && printf 'selected' %>><%= ${wan} %></option>
<% done %>
				</select>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Metric} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" data-validate="num" class="form-control" value=<%= ${metric:-1} %> name="metric">
				  <span class="input-group-addon"><%= ${_LANG_Form_Metric} %></span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %>, 1-1000</span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Weight} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" data-validate="num" class="form-control" value=<%= ${weight:-1} %> name="weight">
				  <span class="input-group-addon"><%= ${_LANG_Form_Weight} %></span>
				</div>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %>, 1-1000</span>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-offset-4 col-sm-8">
				<button type="submit" id="submit_member_btn" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
			</div>
		</div>
	</fieldset>
	</form>
</div>
</div> 
<%
}
edit_policy() {
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${FORM_policy}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
members=$(echo "$mwan3_str" | grep '=member' | cut -d '=' -f1 | cut -d '.' -f2)
%>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Mwan3_Policy_Edit} %>- <%= ${FORM_policy} %></h2>
<div class="col-sm-offset-2 col-sm-6 text-left">
	<form class="form-horizontal text-left" id="set_policy">
	<fieldset>
		<input type="hidden" name="policy" value="<%= ${FORM_policy} %>" />
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Member_in_Policy} %></label>
			<div class="col-sm-8">
<% for member in $members; do %>
  <div class="checkbox">
    <label>
      <input type="checkbox" value="1" name="member_<%= ${member} %>" <% for a_use_member in $use_member; do [ "${a_use_member}" = "${member}" ] && printf 'checked' && break; done %>> <%= ${member} %>
    </label>
  </div>
<% done %>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Member_of_last_resort} %></label>
			<div class="col-sm-8">
				<select name="last_resort" class="form-control">
<% for last_resort_ed in default unreachable blackhole; do %>
					<option value="<%= ${last_resort_ed} %>" <% [ "${last_resort}" = "${last_resort_ed}" ] && printf 'selected' %>><% eval echo '$_LANG_Form_'${last_resort_ed} %></option>
<% done %>
				</select>
				<p class="help-block"><%= ${_LANG_Form_Member_of_last_resort_tip} %></p>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-offset-4 col-sm-8">
				<button type="submit" id="submit_btn" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
			</div>
		</div>
	</fieldset>
	</form>
</div>
</div> 
<%
}
edit_rule() {
eval $(echo "$mwan3_str" | grep -E 'mwan3\.'"${FORM_rule}"'\.' | cut -d '.' -f3- | sed "s#' '# #g")
# < % [ ${sticky} -gt 0 ] && printf '开' || printf '关' % ><br>
%>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Mwan3_Rule_Edit} %>- <%= ${FORM_rule} %></h2>
<div class="col-sm-offset-2 col-sm-6 text-left">
	<form class="form-horizontal text-left" id="set_rule">
	<fieldset>
		<input type="hidden" name="rule" value="<%= ${FORM_rule} %>" />
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Source_addr} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control" data-validate="ips" value="<%= ${src_ip} %>" name="src_ip">
				<span class="help-block hidden"><%= ${_LANG_Form_IP_or_IP__Mask} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Source_port} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control input-sm" data-validate="port" name="src_port" value="<%= ${src_port} %>">
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> 端口值(1-65535)，多个端口之间用逗号分隔</span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Dest_addr} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control" data-validate="ips" value="<%= ${dest_ip} %>" name="dest_ip">
				<span class="help-block hidden"><%= ${_LANG_Form_IP_or_IP__Mask} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Dest_port} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control input-sm" data-validate="port" name="dest_port" value="<%= ${dest_port} %>">
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> 端口值(1-65535)，多个端口之间用逗号分隔</span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Proto} %></label>
			<div class="col-sm-8">
				<select name="proto" class="form-control">
					<option value="all" <% [ -z "${proto}" ] && printf 'selected' %>>all</option>
<%				for a_proto in ip tcp udp icmp esp $(grep -E '^[a-z]' /etc/protocols | awk '{print $1}' | grep -vw -e 'ip' -e 'tcp' -e 'udp' -e 'icmp' -e 'esp' -e 'ipv6'); do %>
					<option value="<%= ${a_proto} %>" <% [ "${proto}" = "${a_proto}" ] && printf 'selected' %>><%= ${a_proto} %></option>
<% done %>
				</select>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Sticky} %></label>
			<div class="col-sm-8">
			  <div class="switch-ctrl head-switch">
				  <input type="checkbox" name="sticky" id="enable_sticky" value="1" <% [ ${sticky} -gt 0 ] && printf 'checked'%> name="sticky">
				  <label for="enable_sticky"><span></span></label>
			  </div>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Sticky_timeout} %></label>
			<div class="col-sm-8">
				<input type="number" min="1" class="form-control input-sm" data-validate="num" name="timeout" value=<%= ${timeout} %>>
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_IPset_chain} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control" value="<%= ${ipset} %>" name="ipset">
				<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_addr} %></span>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${_LANG_Form_Use_Policy} %></label>
			<div class="col-sm-8">
				<select name="use_policy" class="form-control">
<% for policy in $(echo "$mwan3_str" | grep '=policy' | cut -d '=' -f1 | cut -d '.' -f2) default unreachable blackhole; do %>
					<option value="<%= ${policy} %>" <% [ "${policy}" = "${use_policy}" ] && printf 'selected' %>><% if echo ${policy} | grep -qE 'unreachable|blackhole|default'; then eval echo '$_LANG_Form_'${policy}; else echo ${policy};fi %></option>
<% done %>
				</select>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-offset-4 col-sm-8">
				<button type="submit" id="submit_rule_btn" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
			</div>
		</div>
	</fieldset>
	</form>
</div>
</div> 
<%
} %>

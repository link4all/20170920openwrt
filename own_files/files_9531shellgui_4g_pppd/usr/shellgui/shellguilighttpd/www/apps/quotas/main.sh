#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
        <div class="content">
            <div class="app row app-item">
                <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Bandwidth_Quota_Usage} %></h2>
                <div class="col-sm-offset-2 col-sm-2">
                    <select name="" id="host_display" class="form-control">
                        <option value="hostname"><%= ${_LANG_Form_Display_Hostnames} %></option>
                        <option value="ip"><%= ${_LANG_Form_Display_Host_IPs} %></option>
                    </select>
                </div>
                <div class="col-sm-2">
                    <select id="data_display" class="form-control">
                        <option value="pcts"><%= ${_LANG_Form_Percent_Used} %></option>
                        <option value="usds"><%= ${_LANG_Form_Bytes_Used} %></option>
                        <option value="lims"><%= ${_LANG_Form_Limit} %></option>
                    </select>
                </div>
                <div class="col-sm-offset-2 col-sm-10 text-left">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th><%= ${_LANG_Form_Host_s} %></th>
                                    <th><%= ${_LANG_Form_Active} %></th>
                                    <th><%= ${_LANG_Form_Total} %></th>
                                    <th><%= ${_LANG_Form_Down} %></th>
                                    <th><%= ${_LANG_Form_Up} %></th>
                                </tr>
                            </thead>
                            <tbody id="active_quota_container"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <hr>
    	<div class="content">
			<div class="app row app-item">
			  <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_When_Exceeded} ${_LANG_Form_Effect_Mode} %></h2>
			  <div class="col-sm-offset-2 col-sm-10 text-left">
				<p><%= ${_LANG_Form_Effect_Mode_Tip} %></p>
				<div class="row">
				  <div class="col-xs-3 col-sm-2 col-md-2">
					  <label for="" class=""><%= ${_LANG_Form_Effect_Mode} %>:</label>
				  </div>
				  <div class="col-xs-9 col-sm-10 col-md-10">
					<form class="form-inline" name="qos_class_enabled" id="qos_class_enabled">
						<fieldset <% (uci get qos_shellgui.upload.total_bandwidth &>/dev/null && uci get qos_shellgui.download.total_bandwidth &>/dev/null) || printf disabled %>>
							<div class="form-group">
							  <select type="text" class="form-control" name="qos_class_enabled">
									<option value="0"><%= ${_LANG_Form_Throttle_Bandwidth} %></option>
									<option value="1" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/quotas/qos_class_enabled ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Qos_Classification} %></option>
							  </select>
							</div>
							<div class="form-group">
								<button type="submit" class="btn btn-default btn-block"><%= ${_LANG_Form_Apply} %></button>
							</div>
						</fieldset>
					</form>
				  </div>
				</div>
			  </div>
			</div>
		</div>
    	<div class="content">
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12 text-left"><%= ${_LANG_App_name} %></h2>
                <div class="col-sm-offset-2 col-sm-10 text-left">
                    <div class="table-responsive">
                        <table class="table">
							<caption><%= ${_LANG_Form_Current_Quotas} %></caption>
							<thead>
								<tr>
									<th>IP(s)</th>
									<th><%= ${_LANG_Form_Active} %></th>
									<th><%= ${_LANG_Form_Limits}%> <%= ${_LANG_Form__Totals}%></th>
									<th><%= ${_LANG_Form_Enabled} %></th>
									<th></th>
									<th></th>
								</tr>
							</thead>
							<tbody id="quota_container"></tbody>
							<tfoot>
								<tr>
									<td colspan="4">
										<button class="btn btn-success btn-sm" id="add_quota_btn" data-toggle="modal" data-target="#quotaModal"><%= ${_LANG_Form_Add_New_Quota} %></button>
									</td>
								</tr>
							</tfoot>
						</table>
					</div>
				</div>
			</div>
			<hr>
			<div class="app row app-item pull-right">
				<button class="btn btn-default btn-lg" onclick="saveChanges()"><%= ${_LANG_Form_Apply} %></button>
				<button class="btn btn-warning btn-lg" onClick="resetData()"><%= ${_LANG_Form_Reset} %></button>
			</div>
		</div>
	</div> 
</div>
<div class="modal fade" id="quotaModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="quotaModalLabel"><%= ${_LANG_Form_Add_New_Quota} %></h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal">
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Applies_To} %></label>
        		<div class="col-sm-8">
        			<select name="" id="applies_to_type" class="form-control">
        				<option value="all"><%= ${_LANG_Form_Entire_Local_Network} %></option>
        				<option value="only"><%= ${_LANG_Form_Only_the_following_Hosts} %></option>
        				<option value="others_individual"><%= ${_LANG_Form_All_Individual_Hosts_Without_Explicit_Quotas} %></option>
        				<option value="others_combined"><%= ${_LANG_Form_All_Hosts_Without_Explicit_Quotas_Combined} %></option>
        			</select>
        		</div>
        	</div>
        	<div class="form-group hidden">
        		<div class="col-sm-offset-4 col-sm-8">
        			<div id="ip_span_container" data-ips=""></div>
        		</div>
        	</div>
        	<div class="form-group hidden" id="add_ip_input">
                <label for="" class="control-label col-sm-4">指定IP(s)</label>
        		<div class="col-sm-8">
        			<div class="row">
                        <div class="col-xs-9">
        				    <input type="text" id="add_ip" class="form-control">
                        </div>
                        <div class="col-xs-3">
        				    <button class="btn btn-success add_ip_btn">
	        				   <span class="icon-plus"></span>
        				    </button>
                        </div>
        			</div>
    				<span id="add_ip_help" class="help-block hidden"><%= ${_LANG_Form_Specify_an_IP_or_IP_range} %></span>
        		</div>
        	</div>
        	<div class="form-group" id="max_up_form_group">
        		<label id="max_up_label" for="" class="control-label col-sm-4"><%= ${_LANG_Form_Max_Upload} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="max_up_type" class="form-control">
		        				<option value="unlimited"><%= ${_LANG_Form_Unlimited} %></option>
        						<option value="limited"><%= ${_LANG_Form_Limit_To} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-4 col-xs-6 hidden" id="max_up_container">
        					<input type="number" min="0" name="" id="max_up" class="form-control">
                            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                        </div>
                        <div class="col-sm-4 col-xs-6 hidden">
                            <select name="" id="max_up_unit" class="form-control">
                                <option value="MB">MBytes</option>
                                <option value="GB">GBytes</option>
                                <option value="TB">TBytes</option>
                            </select>
                        </div>
                    </div>
        		</div>
        	</div>
        	<div class="form-group" id="max_down_form_group">
        		<label id="max_down_label" for="" class="control-label col-sm-4"><%= ${_LANG_Form_Max_Download} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="max_down_type" class="form-control">
		        				<option value="unlimited"><%= ${_LANG_Form_Unlimited} %></option>
        						<option value="limited"><%= ${_LANG_Form_Limit_To} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-4 col-xs-6 hidden" id="max_down_container">
        					<input type="number" min="0" name="" id="max_down" class="form-control">
                            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                        </div>
                        <div class="col-sm-4 col-xs-6 hidden">
                            <select name="" id="max_down_unit" class="form-control">
                                <option value="MB">MBytes</option>
                                <option value="GB">GBytes</option>
                                <option value="TB">TBytes</option>
                            </select>
                        </div>
                    </div>

        		</div>
        	</div>
        	<div class="form-group" id="max_combined_form_group">
        		<label id="max_combined_label" for="" class="control-label col-sm-4"><%= ${_LANG_Form_Max_Total_Up_Down} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="max_combined_type" class="form-control">
		        				<option value="unlimited"><%= ${_LANG_Form_Unlimited} %></option>
        						<option value="limited"><%= ${_LANG_Form_Limit_To} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-4 col-xs-6 hidden" id="max_combined_container">
        					<input type="number" min="0" name="" id="max_combined" class="form-control">
                            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                        </div>
                        <div class="col-sm-4 col-xs-6 hidden">
                            <select name="" id="max_combined_unit" class="form-control">
                                <option value="MB">MBytes</option>
                                <option value="GB">GBytes</option>
                                <option value="TB">TBytes</option>
                            </select>
                        </div>
                    </div>
                    <span class="help-block hidden" id="max_all_help"><%= ${_LANG_Form_Cant_works_with_both_upload_download_total_all_unlimited} %></span>
                </div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Quota_Resets} %></label>
        		<div class="col-sm-8">
        			<select name="" id="quota_reset" class="form-control">
        				<option value="hour"><%= ${_LANG_Form_Every_Hour} %></option>
						<option value="day"><%= ${_LANG_Form_Every_Day} %></option>
						<option value="week"><%= ${_LANG_Form_Every_Week} %></option>
						<option value="month"><%= ${_LANG_Form_Every_Month} %></option>
        			</select>
        		</div>
        	</div>
        	<div class="form-group hidden">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Reset_Day} %></label>
        		<div class="col-sm-8">
        			<select name="" id="quota_day" class="form-control"></select>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Reset_Hour} %></label>
        		<div class="col-sm-8">
        			<select name="" id="quota_hour" class="form-control">
    					<option value="0"> 12:00 <%= ${_LANG_Form_hAM} %></option>
						<% for hor in $(seq 1 11);do printf "<option value=\"$((3600 * ${hor}))\"> ${hor}:00 ${_LANG_Form_hAM}</option>";done %>
						<option value="43200"> 12:00 <%= ${_LANG_Form_hPM} %></option>
						<% for hor in $(seq 1 11);do printf "<option value=\"$((3600 * ${hor} + 43200))\"> ${hor}:00 ${_LANG_Form_hPM}</option>";done %>
        			</select>
        		</div>
        	</div>
        	<div class="form-group">
        		<label id="quota_active_label" for="" class="control-label col-sm-4"><%= ${_LANG_Form_Quota_Is_Active} %></label>
        		<div class="col-sm-8">
        			<div class="row">
        				<div class="col-sm-12">
		        			<select name="" id="quota_active" class="form-control">
		        				<option value="always"><%= ${_LANG_Form_Always} %></option>
								<option value="only"><%= ${_LANG_Form_Only} %></option>
								<option value="except"><%= ${_LANG_Form_All_Times_Except} %></option>
		        			</select>
        				</div>
        				<div class="col-sm-6 hidden">
        					<select name="" id="quota_active_type" class="form-control">
        						<option value="hours"><%= ${_LANG_Form_These_Hours} %></option>
								<option value="days"><%= ${_LANG_Form_These_Days} %></option>
								<option value="days_and_hours"><%= ${_LANG_Form_These_Days__Hours} %></option>
								<option value="weekly_range"><%= ${_LANG_Form_These_Weekly_Times} %></option>
        					</select>
        				</div>
        			</div>
        		</div>
        	</div>
        	<div class="form-group hidden" id="active_days_container">
        		<div class="col-sm-offset-4 col-sm-8">
        			<label for="quota_sun"><input type="checkbox" id="quota_sun" value="sunday" checked><%= ${_LANG_Form_Sun} %></label>&nbsp;
        			<label for="quota_mon"><input type="checkbox" id="quota_mon" value="monday" checked><%= ${_LANG_Form_Mon} %></label>&nbsp;
        			<label for="quota_tue"><input type="checkbox" id="quota_tue" value="tuesday" checked><%= ${_LANG_Form_Tue} %></label>&nbsp;
        			<label for="quota_wed"><input type="checkbox" id="quota_wed" value="wednesday" checked><%= ${_LANG_Form_Wed} %></label>&nbsp;
        			<label for="quota_thu"><input type="checkbox" id="quota_thu" value="thursday" checked><%= ${_LANG_Form_Thu} %></label>&nbsp;
        			<label for="quota_fri"><input type="checkbox" id="quota_fri" value="friday" checked><%= ${_LANG_Form_Fri} %></label>&nbsp;
        			<label for="quota_sat"><input type="checkbox" id="quota_sat" value="satarday" checked><%= ${_LANG_Form_Sat} %></label>
        		</div>
        	</div>
        	<div class="form-group hidden" id="active_hours_container">
        		<div class="col-sm-offset-4 col-sm-8">
        			<input type="text" id="active_hours" class="form-control">
        			<span class="help-block exam_help">e.g. 02:00-04:00,11:35-13:25</span>
                    <span class="help-block warn_help hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Time_format} %></span>
        		</div>
        	</div>
        	<div class="form-group hidden" id="active_weekly_container">
        		<div class="col-sm-offset-4 col-sm-8">
        			<input type="text" id="active_weekly" class="form-control">
        			<span class="help-block exam_help">e.g. <%= ${_LANG_Form_Mon} %> 00:30 - <%= ${_LANG_Form_Tue} %> 13:15, <%= ${_LANG_Form_Fri} %> 14:00 - <%= ${_LANG_Form_Fri} %> 15:00</span>
                    <span class="help-block warn_help hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Time_format} %></span>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_When_Exceeded} %></label>
        		<div class="col-sm-8">
        			<select name="" id="quota_exceeded" class="form-control">
        				<option value="hard_cutoff"><%= ${_LANG_Form_Shut_Down_All_Internet_Access} %></option>
                        <option value="throttle"><%= ${_LANG_Form_Throttle_Bandwidth} %></option>
        				<option value="combined" class=""><%= ${_LANG_Form_Qos_Classification} %></option>
        			</select>
        		</div>
        	</div>
            <div id="quota_only_qos_container" class="hidden">
            <div class="form-group">
                <label class="control-label col-sm-4"><%= ${_LANG_Form_Upload_Limit} %></label>
                <div class="col-sm-8">
                    <div class="row">
                        <div class="col-xs-6">
                            <input type='number' min="0" id='quota_qos_up' class="form-control">
                            <span class="help-block"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                        </div>
                        <div class="col-xs-6">
                            <select id="quota_qos_up_unit" class="form-control">
                                <option value="KBytes/s">kBytes/s</option>
                                <option value="MBytes/s">MBytes/s</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="control-label col-sm-4"><%= ${_LANG_Form_Download_Limit} %></label>
                <div class="col-sm-8">
                    <div class="row">
                        <div class="col-xs-6">
                            <input type='number' min="0" id='quota_qos_down' class="form-control">
                            <span class="help-block"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                        </div>
                        <div class="col-xs-6">
                            <select id="quota_qos_down_unit" class="form-control">
                                <option value="KBytes/s">kBytes/s</option>
                                <option value="MBytes/s">MBytes/s</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
            </div>
            <div id="quota_full_qos_container" class="hidden">
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Upload_Class} %></label>
        		<div class="col-sm-8">
        			<select name="" id="quota_full_qos_up_class" class="form-control"></select>
        		</div>
        	</div>
        	<div class="form-group">
        		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Download_Class} %></label>
        		<div class="col-sm-8">
        			<select name="" id="quota_full_qos_down_class" class="form-control"></select>
        		</div>
        	</div>
            </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="save_quota"><%= ${_LANG_Form_Add} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="confirm_modal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="confirm_modal_title">Modal Title</h4>
      </div>
      <div class="modal-body center-block">
        <h4 id="modal_ensure_text" class="confirm-msg">确定要开启/关闭。。。么？</h4>
        <a id="modal_result_text" class="text-danger confirm-msg">请移步QOS设置页面开启上传和下载QOS</a>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">确定</button>
        <button type="button" class="btn btn-danger" id="disable_btn" data-dismiss="modal">确定</button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.Specify_an_IP_or_IP_range = "<%= ${_LANG_Form_Specify_an_IP_or_IP_range} %>";
UI.Sun="<%= ${_LANG_Form_Sun} %>";UI.Sunday=UI.Sun;
UI.Mon="<%= ${_LANG_Form_Mon} %>";UI.Monday=UI.Mon;
UI.Tue="<%= ${_LANG_Form_Tue} %>";UI.Tuesday=UI.Tue;
UI.Wed="<%= ${_LANG_Form_Wed} %>";UI.Wednesday=UI.Wed;
UI.Thu="<%= ${_LANG_Form_Thu} %>";UI.Thursday=UI.Thu;
UI.Fri="<%= ${_LANG_Form_Fri} %>";UI.Friday=UI.Fri;
UI.Sat="<%= ${_LANG_Form_Sat} %>";UI.Saturday=UI.Sat;
UI.Always = "<%= ${_LANG_Form_Always} %>";
</script>
<% /usr/shellgui/progs/main.sbin h_end
host_name=$(uci get system.@system[0].hostname | tr -d '\n')
%>
<script>
	var ipToHostname = [];
	var ipsWithHostname = [ "127.0.0.1"<% [ -n "wan_ip" ] && printf ",\"${wan_ip}\"" ;[ -n "lan_ip" ] && printf ",\"${lan_ip}\"" ;awk '{printf ", \""$3"\""}' /tmp/dhcp.leases %> ];
	ipToHostname[ "127.0.0.1" ] = "<%= ${host_name} %>";
<%
[ -n "wan_ip" ] && printf "ipToHostname[ \"${wan_ip}\" ] = \"${host_name}\";" ;
[ -n "lan_ip" ] && printf "ipToHostname[ \"${lan_ip}\" ] = \"${host_name}\";" ;
awk 'length($4)>1{printf "ipToHostname[ \""$3"\" ] = \""$4"\";\n"}' /tmp/dhcp.leases
%>
var uciOriginal = new UCIContainer();
<%
/usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
uci -X -c/usr/shellgui/shellguilighttpd/www/apps/quotas/ show quotas_uci | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
%>
var quotasStr=new Object();
quotasStr.Section="<%= ${_LANG_App_name} %>";
quotasStr.AddQuota="<%= ${_LANG_Form_Add_New_Quota} %>";
quotasStr.ActivQuotas="<%= ${_LANG_Form_Active_Quotas} %>";
quotasStr.IPs="IP(s)";
quotasStr.Active="<%= ${_LANG_Form_Active} %>";
quotasStr.Limits="<%= ${_LANG_Form_Limits} %>";
quotasStr.Totals="<%= ${_LANG_Form__Totals} %>";
quotasStr.OthersOne="<%= ${_LANG_Form_Others__Individual} %>";
quotasStr.OthersAll="<%= ${_LANG_Form_Others__Combined} %>";
quotasStr.Only="<%= ${_LANG_Form_Only} %>";
quotasStr.AllExcept="<%= ${_LANG_Form_All_Times_Except} %>";
quotasStr.AddError="<%= ${_LANG_Form_Could_not_add_quota} %>.";
quotasStr.LD1s="<%= ${_LANG_Form_st} %>";
quotasStr.LD2s="<%= ${_LANG_Form_nd} %>";
quotasStr.LD3s="<%= ${_LANG_Form_rd} %>";
quotasStr.Digs="<%= ${_LANG_Form_th} %>";
quotasStr.IPError="<%= ${_LANG_Form_You_must_specify_at_least_one_valid_IP_or_IP_range} %>";
quotasStr.AllUnlimitedError="<%= ${_LANG_Form_AllUnlimitedError} %>";
quotasStr.DuplicateRange="<%= ${_LANG_Form_DuplicateRange} %>";
quotasStr.OneTimeQuotaError="<%= ${_LANG_Form_OneTimeQuotaError} %>";
quotasStr.OneNetworkQuotaError="<%= ${_LANG_Form_OneNetworkQuotaError} %>";
quotasStr.QuotaAddError="<%= ${_LANG_Form_Could_not_add_quota} %>.";
quotasStr.NA="NA";
var qosEnabled = true;
var qosMarkList = [];
var fullQosEnabled = true;
<%
uci show -X qos_shellgui | grep -E 'class_|upload|download|_rule_' | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
/usr/shellgui/progs/qos_shellgui print_all_mark | awk '{ print "qosMarkList.push([\""$1"\",\""$2"\",\""$3"\",\""$4"\"]);" }'
p_quotas %>
var uci = uciOriginal.clone();
    $('#qos_class_enabled').submit(function(e){
      e.preventDefault();
      var data = "app=quotas&action=qos_class_enabled&"+$(this).serialize();
      Ha.disableForm('qos_class_enabled');
      Ha.ajax('/','json',data,'post','qos_class_enabled',Ha.showNotify,1);
    });
</script>
<script src="/apps/quotas/quotas.js"></script>
</body>
</html>

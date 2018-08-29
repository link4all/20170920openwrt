#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "download_bandwidth_csv" ] &>/dev/null; then
	grep bw-gain /tmp/bw_backup/do_bw_backup.sh | sed -e 's/.*bw-gain/bw-gain/' -e 's/\-f .*/-t/g' | while read line; do eval "${line}";done | tr -s "\n" | sed -e 's/^[^\-]*\-//g' -e 's/\-/,/g' | /usr/shellgui/progs/main.sbin http_download bandwidth-$(date +%Y-%m-%d_%H-%M).csv
return
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
		<!-- 数据表单 -->
		<div class="hidden">
			<select id="plot_time_frame" onchange="resetPlots()">
				<option value="1">15 <%= ${_LANG_Form_minutes} %></option>
				<option value="2"> 6 <%= ${_LANG_Form_hours} %></option>
				<option value="3">24 <%= ${_LANG_Form_hours} %></option>
				<option value="4">30 <%= ${_LANG_Form_days} %></option>
				<option value="5"> 1 <%= ${_LANG_Form_year} %></option>
			</select>
			<input type="checkbox" id="use_high_res_15m" onclick="highResChanged()">
		</div>
		<!-- 操作按钮 -->
		<div class="content">
	      <div class="app row app-item">
        	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Bandwidth_Graphs} %></h2>
	        <div class="col-sm-12 text-left" style="margin-bottom: 20px">
				<div class="btn-group hidden-xs">
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_1">15 <%= ${_LANG_Form_minutes} %></button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_2">6 <%= ${_LANG_Form_hours} %></button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_3">24 <%= ${_LANG_Form_hours} %></button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_4">30 <%= ${_LANG_Form_days} %></button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_5">1 <%= ${_LANG_Form_year} %></button>
				</div>
				<div class="btn-group visible-xs">
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_xs_1">15m</button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_xs_2">6h</button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_xs_3">24h</button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_xs_4">30d</button>
					<button type="button" class="tf_btn btn btn-default btn-sm" id="plot_tf_xs_5">1y</button>
				</div>
	        </div>
			<div class="col-xs-12 btn-group pull-left">
	        	<select id="plot1_type" class="btn btn-info btn-sm" onchange="resetPlots()" >
					<option value="total"><%= ${_LANG_Form_Total_Bandwidth} %></option>
				</select>
				<select id="plot1_id" class="btn btn-info btn-sm" onchange="resetPlots()" class="hidden"></select>
			</div>
			<div class="col-xs-12 pull-left btn-group">
				<select id="plot2_type" class="btn btn-success btn-sm" onchange="resetPlots()" >
					<option value="none"><%= ${_LANG_Form_None} %></option>
				</select>
				<select id="plot2_id" class="btn btn-success btn-sm" onchange="resetPlots()" class="hidden"></select>
			</div>
			<div class="col-xs-12 pull-left btn-group">
				<select id="plot3_type" class="btn btn-danger btn-sm" onchange="resetPlots()">
					<option value="none"><%= ${_LANG_Form_None} %></option>
				</select>
				<select id="plot3_id" class="btn btn-danger btn-sm" onchange="resetPlots()" class="hidden"></select>
			</div>
	      </div>
	    </div>
	    <!-- 图 -->
	    <div class="content">
	      	<div class="app row app-item">
				<div class="col-sm-12 canvas_container" id="total_container">
					<canvas id="my_total" height="300"></canvas>
				</div>
				<div class="col-sm-6 canvas_container" id="download_container">
					<canvas id="my_download" height="300"></canvas>
				</div>
				<div class="col-sm-6 canvas_container" id="upload_container">
					<canvas id="my_upload" height="300"></canvas>
				</div>
			</div>
		</div>
		<hr>
		<!-- 表格 -->
		<div class="content">
	      	<div class="app row app-item">
	        	<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Bandwidth_Usage_Table} %></h2>
				<div class="form-horizontal text-left col-sm-6">
					<div class="form-group">
						<label for="table_time_frame" class="control-label col-sm-4"><%= ${_LANG_Form_Display_Interval} %></label>
						<div class="col-sm-8">
							<select name="" id="table_time_frame" class="form-control" onchange="resetPlots()">
								<option value="1"><%= ${_LANG_Form_minutes} %></option>
								<option value="2"><%= ${_LANG_Form_quarter_hours} %></option>
								<option value="3"><%= ${_LANG_Form_hours} %></option>
								<option value="4"><%= ${_LANG_Form_days} %></option>
								<option value="5"><%= ${_LANG_Form_months} %></option>
							</select>
						</div>
					</div>
					<div class="form-group">
						<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Display_Type} %></label>
						<div class="col-sm-8">
							<select id="table_type" class="form-control" onchange="resetPlots()">
								<option value="total"><%= ${_LANG_Form_Total_Bandwidth} %></option>
							</select>
						</div>
					</div>
					<div id="table_id_container" class="form-group hidden">
						<label for='table_id' class="control-label col-sm-4" id='total_id_label'><%= ${_LANG_Form_Display_Id} %>:</label>
						<div class="col-sm-8">
							<select id="table_id" class="form-control" onchange="resetPlots()"></select>	
						</div>
					</div>
					<div class="form-group">
						<label for="table_units" class="control-label col-sm-4"><%= ${_LANG_Form_Table_Units} %></label>
						<div class="col-sm-8">
							<select name="" id="table_units" class="form-control" onchange="resetPlots()">
								<option value="mixed"><%= ${_LANG_Form_Auto_mixed} %></option>
								<option value="KBytes">KBytes</option>
								<option value="MBytes">MBytes</option>
								<option value="GBytes">GBytes</option>
								<option value="TBytes">TBytes</option>
							</select>
						</div>
					</div>
				</div>
				<div class="col-sm-12 table-responsive text-left">
					<table class="table">
						<thead>
							<tr>
								<th><%= ${_LANG_Form_Time} %></th>
								<th><%= ${_LANG_Form_Total} %></th>
								<th><%= ${_LANG_Form_Download} %></th>
								<th><%= ${_LANG_Form_Upload} %></th>
							</tr>
						</thead>
						<tbody id="bw_table_container"></tbody>
						<tfoot>
							<tr>
								<td colspan="4">
									<button type="submit" id="del_data" class="btn btn-danger"><%= ${_LANG_Form_DELETE_DATA} %></button>
									<a href="/?app=bandwidth-usage&action=download_bandwidth_csv"><button class="btn btn-default" title="<%= ${_LANG_Form_Data_is_comma_separated} %>:<%= ${_LANG_Form_Data_FMT} %>"><%= ${_LANG_Form_DOWNLOAD_DATA} %></button></a>
								</td>
							</tr>
						</tfoot>
					</table>
				</div>
			</div>
		</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.EMonths=[<%= ${_LANG_Form_EMonths} %>];
</script>
<% /usr/shellgui/progs/main.sbin h_end %>
<script>
$('#del_data').click(function(){
  var r=confirm("<%= ${_LANG_Form_Do_you_want_to_DELETE_DATA} %>")
  if (r==true) {
	$.post('/','app=bandwidth-usage&action=del_data',Ha.showNotify,'json');
	}
});
<%
/usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
wanzone=$(uci get qos_shellgui.global.network)
bw_str=$(shellgui '{"action":"get_ifces_status"}')
wan_str=$(ubus call network.interface.${wanzone} status)
lan_str=$(ubus call network.interface.lan status)

wan_dev=$(echo "$wan_str" | jshon -e "device" -u)
currentWanIf=$(echo "$wan_str" | jshon -e "l3_device" -u)
lan_dev=$(echo "$lan_str" | jshon -e "device" -u)
currentLanName=$(echo "$lan_str" | jshon -e "l3_device" -u)

wan_ip=$(echo "$wan_str" | jshon -e "ipv4-address" -e 0 -e "address" -u)
lan_ip=$(echo "$lan_str" | jshon -e "ipv4-address" -e 0 -e "address" -u)

wan_mask=$(echo "$wan_str" | jshon -e "ipv4-address" -e 0 -e "mask")
eval $(ipcalc.sh ${wan_ip} ${wan_mask})
wan_mask="${NETMASK}"

lan_mask=$(echo "$lan_str" | jshon -e "ipv4-address" -e 0 -e "mask")
eval $(ipcalc.sh ${lan_ip} ${lan_mask})
lan_mask="${NETMASK}"

wan_mac=$(echo "$bw_str" | jshon -e "${wan_dev}" -e "mac" -u)
lan_mac=$(echo "$bw_str" | jshon -e "${lan_dev}" -e "mac" -u)

gateway=$(echo "$wan_str" | jshon -e "route" -e 0 -e "nexthop" -u)
[ "$gateway" = "0.0.0.0" ] && gateway=$(echo "$wan_str" | jshon -e "route" -e 1 -e "nexthop" -u)
host_name=$(uci get system.@system[0].hostname | tr -d '\n')
%>
	var wirelessIfs = [  ];
	var uciWirelessDevs = [  ];
	var currentWirelessMacs = [  ];
	var defaultLanIf = "<% uci get network.lan.ifname | tr -d '\n' %>";
	var currentLanIf = "<% uci get network.lan.ifname | tr -d '\n' %>";
	var currentLanName = "<%= ${currentLanName} %>";
	var currentLanMac = "<%= ${lan_mac} %>";
	var currentLanIp = "<%= ${lan_ip} %>";
	var currentLanMask = "<%= ${lan_mask} %>";
	var defaultWanIf = "<%= ${wan_dev} %>";
	var defaultWanMac = "<%= ${lan_mac} %>";
	var currentWanIf = "<%= ${currentWanIf} %>";
	var currentWanName = "<%= ${wan_dev} %>";
	var currentWanMac = "<%= ${wan_mac} %>";
	var currentWanIp = "<%= ${wan_ip} %>";
	var currentWanMask = "<%= ${wan_mask} %>";
	var currentWanGateway = "<%= ${gateway} %>";
	var ipToHostname = [];
	var ipsWithHostname = [ "127.0.0.1"<% [ -n "wan_ip" ] && printf ",\"${wan_ip}\"" ;[ -n "lan_ip" ] && printf ",\"${lan_ip}\"" ;awk '{printf ", \""$3"\""}' /tmp/dhcp.leases %> ];
	ipToHostname[ "127.0.0.1" ] = "<%= ${host_name} %>";
<%
[ -n "wan_ip" ] && printf "ipToHostname[ \"${wan_ip}\" ] = \"${host_name}\";" ;
[ -n "lan_ip" ] && printf "ipToHostname[ \"${lan_ip}\" ] = \"${host_name}\";" ;
awk 'length($4)>1{printf "ipToHostname[ \""$3"\" ] = \""$4"\";\n"}' /tmp/dhcp.leases
%>
	var uciOriginal = new UCIContainer();
	uciOriginal.set('shellgui', 'bandwidth_display', '', "bandwidth_display");
	uciOriginal.set('gargoyle', 'bandwidth_display', 'high_res_15m', "0");
<%
uci show -X qos_shellgui | grep -E 'class_|upload|download|_rule_' | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
%>
  var monitorNames = new Array();
<%
iptables-save |grep  "bandwidth--id" | awk -F "bandwidth--id " '{split($2,a," " ); print "monitorNames.push(\""a[1]"\");"}' | sort -n | uniq
%>
  var tzMinutes = 480;
</script>
<script src="/apps/home/common/js/Chart.js"></script>
<script src="/apps/bandwidth-usage/bandwidth.js"></script>
</body>
</html>

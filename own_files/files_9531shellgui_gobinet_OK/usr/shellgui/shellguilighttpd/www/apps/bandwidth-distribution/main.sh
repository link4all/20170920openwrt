#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>

<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
		<div class="hidden">
			<select id="time_frame" onchange="resetTimeFrame()">
				<option value="bdist1"><%= ${_LANG_Form_minutes} %></option>
				<option value="bdist2"><%= ${_LANG_Form_quarter_hours} %></option>
				<option value="bdist3"><%= ${_LANG_Form_hours} %></option>
				<option value="bdist4"><%= ${_LANG_Form_days} %></option>
				<option value="bdist5"><%= ${_LANG_Form_months} %></option>
			</select>
		</div>
		<div class="content">
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_App_name} %></h2>
				<div class="col-sm-12 text-left" style="margin-bottom: 20px">
					<div class="btn-group">
						<button type="button" class="tf_btn btn btn-default btn-sm active" id="bdistf_1"><%= ${_LANG_Form_minutes} %></button>
						<button type="button" class="tf_btn btn btn-default btn-sm" id="bdistf_2"><%= ${_LANG_Form_quarter_hours} %></button>
						<button type="button" class="tf_btn btn btn-default btn-sm" id="bdistf_3"><%= ${_LANG_Form_hours} %></button>
						<button type="button" class="tf_btn btn btn-default btn-sm" id="bdistf_4"><%= ${_LANG_Form_days} %></button>
						<button type="button" class="tf_btn btn btn-default btn-sm" id="bdistf_5"><%= ${_LANG_Form_months} %></button>
					</div>

					<div class="btn-group">
						<select class="btn btn-default btn-sm" id="time_interval" onchange="resetDisplayInterval()">
							<option value=""></option>
						</select>
						<select class="btn btn-default btn-sm" id="host_display" onchange="resetTimeFrame()">
							<option value="hostname"><%= ${_LANG_Form_Display_Hostnames} %></option>
							<option value="ip"><%= ${_LANG_Form_Display_Host_IPs} %></option>
						</select>
					</div>
				</div>
				<!-- <div class="col-sm-6 text-left" style="margin-bottom: 20px" id="legend_container"></div> -->
				<div id="pie_chart_container">
				<!-- <div class="col-sm-6 text-left" style="margin-bottom: 20px" >
					<canvas id="total_pie" height="200"></canvas>
				</div>
				<div class="col-sm-6 text-left" style="margin-bottom: 20px" >
					<canvas id="down_pie" height="200"></canvas>
				</div>
				<div class="col-sm-6 text-left" style="margin-bottom: 20px" >
					<canvas id="up_pie" height="200"></canvas>
				</div> -->
					<div class="col-sm-4 text-center">
						<div id="total" class="pie-container"></div>
					</div>
					<div class="col-sm-4 text-center">
						<div id="down" class="pie-container"></div>
					</div>
					<div class="col-sm-4 text-center">
						<div id="up" class="pie-container"></div>
					</div>
				</div>
				<div class="col-sm-12" id="label-container"></div>

			</div>
			<hr>
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Bandwidth_Distribution_Table} %></h2>
				<div class="col-sm-12 text-left table-responsive" style="margin-bottom: 20px">
					<table class="table">
						<thead>
							<tr>
								<th><%= ${_LANG_Form_Host} %></th>
								<th><%= ${_LANG_Form_Total} %></th>
								<th><%= ${_LANG_Form_Down} %></th>
								<th><%= ${_LANG_Form_Up} %></th>
								<th><%= ${_LANG_Form_Total} %> %</th>
								<th><%= ${_LANG_Form_Down} %> %</th>
								<th><%= ${_LANG_Form_Up} %> %</th>
							</tr>
						</thead>
						<tbody id="bdist_data_container"></tbody>
					</table>
				</div>
			</div>
		</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.monthNames=[<%= ${_LANG_Form_monthNames} %>];
UI.Sum = '<%= ${_LANG_Form_Sum} %>';
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
monitorNames = new Array();
<%
iptables-save |grep  "bandwidth--id" | awk -F "bandwidth--id " '{split($2,a," " ); print "monitorNames.push(\""a[1]"\");"}' | sort -n | uniq
%>
</script>
<script src="/apps/home/common/js/d3.v3.min.js"></script>
<script src="/apps/bandwidth-distribution/bdist_chart.js"></script>
<script src="/apps/bandwidth-distribution/bdist.js"></script>
</body>
</html>

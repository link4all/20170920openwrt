#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
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
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
		<div class="container loading">
		    <div class="icon-loading">
				<span></span>
				<span></span>
				<span></span>
				<span></span>
				<span></span>
				<div class="loading-text"><%= ${_LANG_Form_Loading} %>...</div>
		    </div>
	  	</div>
    	<div class="row">
    		<div class="app app-item col-lg-12">
		        <div class="row">
		            <div class="col-sm-12">
		                <h2 class="app-sub-title"><%= ${_LANG_Form_Current_Connections} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-6">
	                    <div class="form-horizontal text-left">
	                    	<div class="form-group">
	                    		<label for="" class="col-sm-4"><%= ${_LANG_Form_Refresh_Rate} %></label>
	                    		<div class="col-sm-8">
	                    			<select name="" id="refresh_rate" class="form-control">
				                    	<option value="2000">2 <%= ${_LANG_Form_Secs} %></option>
				                    	<option value="10000">10 <%= ${_LANG_Form_Secs} %></option>
				                    	<option value="30000">30 <%= ${_LANG_Form_Secs} %></option>
				                    	<option value="60000">60 <%= ${_LANG_Form_Secs} %></option>
				                    	<option value="never"><%= ${_LANG_Form_Never} %></option>
				                    </select>
	                    		</div>
	                    	</div>
	                    	<div class="form-group">
	                    		<label for="" class="col-sm-4"><%= ${_LANG_Form_Bandwidth_Units} %></label>
	                    		<div class="col-sm-8">
	                    			<select name="" id="bw_units" class="form-control">
				                    	<option value="mixed"><%= ${_LANG_Form_Auto__Mixed} %></option>
				                    	<option value="KBytes">KBytes</option>
				                    	<option value="MBytes">MBytes</option>
				                    	<option value="GBytes">GBytes</option>
				                    </select>
	                    		</div>
	                    	</div>
	                    	<div class="form-group">
	                    		<label for="" class="col-sm-4"><%= ${_LANG_Form_Show_Hosts} %></label>
	                    		<div class="col-sm-8">
	                    			<select name="" id="host_display" class="form-control">
				                    	<option value="hostname"><%= ${_LANG_Form_Show_Hostsname} %></option>
				                    	<option value="ip"><%= ${_LANG_Form_Show_Hosts_IP} %></option>
				                    </select>
	                    		</div>
	                    	</div>
	                    </div>
		            </div>
                    <div class="table-responsive col-sm-offset-1 col-sm-11">
                    	<table class="table">
                    		<thead class="hidden">
                    			<tr>
                    				<th><%= ${_LANG_Form_Proto} %></th>
                    				<th><%= ${_LANG_Form_LAN_Host_WAN_Host} %></th>
                    				<th><%= ${_LANG_Form_Bytes_Up_Down} %></th>
                    				<th><%= ${_LANG_Form_QoS_Up_Down} %></th>
                    				<th><%= ${_LANG_Form_L7_Proto} %></th>
                    			</tr>
                    		</thead>
                    		<tbody id="links_container"></tbody>
                    		<tfoot>
                    			<tr>
                    				<th colspan="5">
                    					<p><%= ${_LANG_Form_Connections_between_local_hosts_and_the_router_are_not_displayed} %>.</p>
                    				</th>
                    			</tr>
                    		</tfoot>
                    	</table>
                    </div>
		        </div>
		    </div>
    	</div>
	</div> 
</div>

<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end

wanzone=$(uci get qos_shellgui.global.network)
bw_str=$(shellgui '{"action": "get_ifces_status"}')
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
<script>
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
# awk 'length($4)>1{printf "ipToHostname[ \""$3"\" ] = \""$4"\";"}' /tmp/dhcp.leases
awk 'length($4)>1{printf "ipToHostname[ \""$3"\" ] = \""$4"\";\n"}' /tmp/dhcp.leases
%>
var uciOriginal = new UCIContainer();
var qosEnabled = true;
var qosMarkList = [];
<%
uci show -X qos_shellgui | grep -E 'class_|upload|download|_rule_' | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
awk '{ print "qosMarkList.push([\""$1"\",\""$2"\",\""$3"\",\""$4"\"]);" }' /usr/shellgui/progs/firewall_lib/qos_class_marks
%>
</script>
<script src="/apps/conntrack/conntrack.js"></script>
</body>
</html>
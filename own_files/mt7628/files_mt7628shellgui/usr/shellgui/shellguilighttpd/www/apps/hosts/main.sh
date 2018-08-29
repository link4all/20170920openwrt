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
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
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
		                <h2 class="app-sub-title"><%= ${_LANG_Form_Refresh_Rate} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-3">
	                    <select name="" id="refresh_rate" class="form-control" >
	                    	<option value="2000">2 <%= ${_LANG_Form_Secs} %></option>
	                    	<option value="10000" selected>10 <%= ${_LANG_Form_Secs} %></option>
	                    	<option value="30000">30 <%= ${_LANG_Form_Secs} %></option>
	                    	<option value="60000">60 <%= ${_LANG_Form_Secs} %></option>
	                    	<option value="never"><%= ${_LANG_Form_Never} %></option>
	                    </select>
		            </div>
		        </div>
		        <hr>
		        <div class="row hidden" id="dhcp_data">
		            <div class="col-sm-6">
		                <h2 class="app-sub-title"><%= ${_LANG_Form_Current_DHCP_Leases} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-11">
		                <div class="table-responsive">
		                    <table class="table">
		                    	<thead>
		                    		<tr>
		                    			<th><%= ${_LANG_Form_Hostname} %></th>
		                    			<th><%= ${_LANG_Form_Host_IP} %></th>
		                    			<th><%= ${_LANG_Form_Host_MAC} %></th>
		                    			<th><%= ${_LANG_Form_Lease_Expires} %></th>
		                    		</tr>
		                    	</thead>
		                    	<tbody id="dhcp_container"></tbody>
		                    </table>
		                </div>
		            </div>
		        </div>
		        <hr>
		        <div class="row hidden" id="wifi_data">
		            <div class="col-sm-6">
		                <h2 class="app-sub-title"><%= ${_LANG_Form_Connected_Wireless_Hosts} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-11">
		                <div class="table-responsive">
		                    <table class="table">
		                    	<thead>
		                    		<tr>
		                    			<th><%= ${_LANG_Form_Hostname} %></th>
		                    			<th><%= ${_LANG_Form_Host_IP} %></th>
		                    			<th><%= ${_LANG_Form_Host_MAC} %></th>
		                    			<th><%= ${_LANG_Form_Band} %></th>
		                    			<th>TX <%= ${_LANG_Form_Bitrate} %></th>
		                    			<th>RX <%= ${_LANG_Form_Bitrate} %></th>
		                    			<th><%= ${_LANG_Form_Signal} %></th>
		                    		</tr>
		                    	</thead>
		                    	<tbody id="wifi_container"></tbody>
		                    </table>
		                </div>
		            </div>
		        </div>
		        <hr>
		        <div class="row" id="active_data">
		            <div class="col-sm-6">
		                <h2 class="app-sub-title"><%= ${_LANG_Form_Hosts_With_Active_Connections} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-11">
		                <div class="table-responsive">
		                    <table class="table">
		                    	<thead>
		                    		<tr>
		                    			<th><%= ${_LANG_Form_Hostname} %></th>
		                    			<th><%= ${_LANG_Form_Host_IP} %></th>
		                    			<th><%= ${_LANG_Form_Host_MAC} %></th>
		                    			<th><%= ${_LANG_Form_Active_TCP_Cxns} %></th>
		                    			<th><%= ${_LANG_Form_Recent_TCP_Cxns} %></th>
		                    			<th><%= ${_LANG_Form_UDP_Cxns} %></th>
		                    		</tr>
		                    	</thead>
		                    	<tbody id="active_container"></tbody>
		                    </table>
		                </div>
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
awk 'length($4)>1{printf "ipToHostname[ \""$3"\" ] = \""$4"\";\n"}' /tmp/dhcp.leases
%>
var uciOriginal = new UCIContainer();
<%
uci show -X dhcp | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
uci show -X wireless | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
/usr/shellgui/progs/define_host_vars.sh
%>
</script>
<script src="/apps/hosts/hosts.js"></script>
</body>
</html>
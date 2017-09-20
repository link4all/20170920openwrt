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
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title": "'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
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
	    	<div class="col-sm-12">
	    		<div class="table-responsive hidden">
	    		<!-- <div>
	    			<div id="info_container" class="hidden">
	    				<p>Wake on LAN (WoL) is an Ethernet computer networking standard that allows a computer to be turned on or woken up by a network message. The message is sent by a program executed on the router on the same local area network.</p>
	    				<p>This special network message is called the magic packet and it contains the MAC address of the destination computer. The listening computer waits for a magic packet addressed to it and then initiates system wake up.</p>
	    				<p>Wake on LAN usually needs to be enabled in the Power Management section of a PC motherboard's BIOS setup utility. In addition, in order to get Wake on LAN to work it is sometimes required to enable this feature on the network interface card or on-board silicon device driver.</p>
	    			</div>
	    			<a id="more_info_togger" href="">More Info</a>
	    		</div> --!>
					<table class="table">
						<thead>
							<tr>
								<th><%= ${_LANG_Form_Hostname} %></th>
								<th>IP</th>
								<th>MAC</th>
								<th></th>
							</tr>
						</thead>
						<tbody id="host_container"></tbody>
					</table>
	    		</div>
	    	</div>
    	</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end
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
lan_bcast="${BROADCAST}"

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
var etherData = new Array();
currentWanIp="<%= ${wan_ip} %>";
currentLanIp="<%= ${lan_ip} %>";
var bcastIp="<%= ${lan_bcast} %>";
</script>
<script src="/apps/wol/wol.js"></script>
</body>
</html>

#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/netstatus.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Main page</title>
<script type="text/javascript" src="/jjs/jquery.js"></script>
<link rel="stylesheet" type="text/css" href="css/form.css" />
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript">
function clear_4g(){
$.ajax({
       url: "/cgi-bin/clear4g.sh",
       type: "POST",
       cache: false,
       //data: form,
       processData:false,
       contentType:false,
       success: function(json) {
         $("#used_byte").html("0");
         }
       });
}

      function get4ginfo(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/get4ginfo.sh",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
            var sim = document.getElementById('sim'); 
            var sig = document.getElementById('sig');
            var imei = document.getElementById('imei'); 
            var imsi = document.getElementById('imsi');
            var iccid = document.getElementById('iccid');        
            sim.innerHTML=json.sim
            sig.innerHTML=json.sig
            imei.innerHTML=json.imei
            imsi.innerHTML=json.imsi
            iccid.innerHTML=json.iccid
           
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
	  $(window).on('load', function () {
      get4ginfo()
      });
    </script>

</head>
<body>
<div class="current"><%= $location%></div>
<div class="wrap-main" style="position: relative;min-height: 100%">
		<div class="wrap">
				<div class="title"><%= $wan_status%></div>
				<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" >
									<tr>
												<td><%= $wan_if%></td>
												<td><%= $ip_addr%></td>
                        <td>GateWaye</td>
                        <td>NetMask</td>
                        <td >DNS</td>
                        <td ><%= $run_time%></td>
									</tr>
									<tr>
												<td >WAN</td>
                        <td><% w_ip=`ubus call network.interface.wan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
                          if  [ -z $w_ip ] ;then
                           echo  "$no_connect"
                           else
                           echo $w_ip
                           fi
                            %></td>
                        <td><% ubus call network.interface.wan status |jsonfilter -e "@['route'][-1].nexthop" %></td>
                        <td><% ifconfig eth0.2 |grep "inet addr"|awk '{print $4}' |cut -d: -f2 %></td>
                        <td><%  ubus call network.interface.wan status |jsonfilter -e "@['dns-server'][*]" | sed ":a;N;s/\n/<br \/>/g;ta" %></td>
												<td><% ubus call network.interface.wan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, " %></td>
                    </tr>
                    <tr>
                        <td>4G</td>
                        <td><% g4_ip=`ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
                          if  [ -z $g4_ip ] ;then
                           echo  "$no_connect"
                           else
                           echo $g4_ip
                           fi
                            %></td>
                            <td><% ubus call network.interface.4g status |jsonfilter -e "@['route'][-1].nexthop" %></td>
                            <td><% ifconfig eth1 |grep "inet addr"|awk '{print $4}' |cut -d: -f2 %></td>
                            <td><%  ubus call network.interface.4g status |jsonfilter -e "@['dns-server'][*]" | sed ":a;N;s/\n/<br \/>/g;ta" %></td>
                            <td><% ubus call network.interface.4g status |grep "uptime" |cut -d: -f2 |tr -d "\"\, " %></td>
                      </tr>
                    <tr>
                      <td>WWAN</td>
                      <td><% ww_ip=`ubus call network.interface.wwan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
                        if  [ -z $ww_ip ] ;then
                         echo  "$no_connect"
                         else
                         echo $ww_ip
                         fi
                          %></td>
                      <td><% ubus call network.interface.wwan status |jsonfilter -e "@['route'][-1].nexthop" %></td>
                      <td><% ifconfig apcli0 |grep "inet addr"|awk '{print $4}' |cut -d: -f2 %></td>
                      <td><%  ubus call network.interface.wwan status |jsonfilter -e "@['dns-server'][*]" | sed ":a;N;s/\n/<br \/>/g;ta" %></td>
                      <td><% ubus call network.interface.wwan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, " %></td>
                    </tr>
                    <tr>
                        <td>VPN </td>
                        <td><% 
                          if [ "`ifconfig pptp-pptp |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                            pptp_ip=`ubus call network.interface.pptp status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
                            pptp_ut=`ubus call network.interface.pptp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "`
                            echo "PPTP $pptp_ip"
                            vpn_gw=`ubus call network.interface.pptp status |jsonfilter -e "@['route'][-1].nexthop"`
                            vpn_netmask=`ifconfig pptp-pptp |grep "inet addr"|awk '{print $4}' |cut -d: -f2`
                            vpn_dns=`ubus call network.interface.pptp status |jsonfilter -e "@['dns-server'][*]" | sed ":a;N;s/\n/<br \/>/g;ta"`
                            vpn_uptime=`ubus call network.interface.pptp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "`
                         elif [ "`ifconfig l2tp-l2tp |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                            l2tp_ip=`ubus call network.interface.l2tp status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
                            l2tp_ut=`ubus call network.interface.pptp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "`
                            echo "L2TP $l2tp_ip"
                            vpn_gw=`ubus call network.interface.l2tp status |jsonfilter -e "@['route'][-1].nexthop"`
                            vpn_netmask=`ifconfig l2tp-l2tp |grep "inet addr"|awk '{print $4}' |cut -d: -f2`
                            vpn_dns=`ubus call network.interface.l2tp status |jsonfilter -e "@['dns-server'][*]" | sed ":a;N;s/\n/<br \/>/g;ta"`
                            vpn_uptime=`ubus call network.interface.l2tp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "`
                         elif [ "`ifconfig tun0 |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                            openvpn_ip=`ubus call network.interface.openvpn status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` 
                            openvpn_ut=`ubus call network.interface.pptp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "`
                            echo "OPENVPN $openvpn_ip"
                            vpn_gw=`ubus call network.interface.tun0 status |jsonfilter -e "@['route'][-1].nexthop"`
                            vpn_netmask=`ifconfig tun0 |grep "inet addr"|awk '{print $4}' |cut -d: -f2`
                            vpn_dns=`ubus call network.interface.tun0 status |jsonfilter -e "@['dns-server'][*]" | sed ":a;N;s/\n/<br \/>/g;ta"`
                            vpn_uptime=`ubus call network.interface.tun0 status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "`
                            else
                            echo "$no_connect"
                          fi %>
                        </td>
                          <td><%= $vpn_gw %></td>
                           <td><%= $vpn_netmask %></td>
                           <td><%= $vpn_dns %></td>
                           <td><%= $vpn_uptime  %></td>
                  

                        </tr>
                </table>
                <div class="title"><%= $lan_info%></div>
                <div class="wrap-table">
                <table border="0" cellspacing="0" cellpadding="0" id="brinfo" >
                    <tr>
												<td  width="20%" >LAN IP</td>
												<td ><% uci get network.lan.ipaddr 2>/dev/null %></td>
										</tr>
										<tr>
												<td >NetMask</td>
												<td ><% uci get network.lan.netmask 2>/dev/null %></td>
										</tr>
                </table>  
                </div>
                </div>  
					<div class="title"><%= $modem_info%></div>
						<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" id="4ginfo" >

										<tr>
												<td  width="20%" ><%= $g4_model%></td>
												<td colspan="3" ><%= `uci get 4g.modem.rev 2>/dev/null` %></td>
										</tr>
										<tr>
												<td ><%= $sim_status%></td>
												<td colspan="3" id="sim"></td>
										</tr>
										<tr>
												<td ><%= $sig%></td>
												<td colspan="3" id="sig"></td>
                    </tr>
                    <tr>
												<td >IMEI</td>
												<td colspan="3" id="imei"></td>
                    </tr>
                    <tr>
												<td >IMSI</td>
												<td colspan="3" id="imsi"></td>
                    </tr>
                    <tr>
												<td >ICCID</td>
												<td colspan="3" id="iccid"></td>
										</tr>
										<tr>
												<td ><%= $used_byte%></td>
												<td id="used_byte"  colspan="2">
                          <% rx=`vnstat -i eth1 --json |jsonfilter -e @.interfaces[0].traffic.total.rx`
                          tx=`vnstat -i eth1 --json |jsonfilter -e @.interfaces[0].traffic.total.tx`
                          if [ -z  $rx  ];then
                          rx=0
                          tx=0
                          fi
                          g4byte=$(($rx+$tx))
                          if [ $g4byte -ge 1000000 ];then
                          g4byte=`awk -v x=$g4byte  'BEGIN{printf "%.2fGB",x/1024/1024}'`
                          elif [ $g4byte -ge 1000 ]; then
                           g4byte=`awk -v x=$g4byte  'BEGIN{printf "%.2fMB",x/1024}'`
                          else
                           g4byte=`awk -v x=$g4byte   'BEGIN{printf "%dKB",x}'`
                          fi %>
                          <%= $g4byte %>
</td>
                        </tr>
							</table>
              <br />
              <div class="btn-wrap">
              <div class="save-btn fr"><a href="javascript:clear_4g()"><%= $clear%></a></div>
            </div>
						</div>
				</div>
		</div>
</div>
</body>
</html>



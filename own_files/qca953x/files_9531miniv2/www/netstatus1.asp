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

function myrefresh() 
{ 
  $('.myrefresh').attr('href', '#');
  // alert($('.myrefresh').attr('href'));
  $("#status").html("<%= $on_processing %>");
$.ajax({
       url: "/cgi-bin/get4ginfo.sh",
       type: "POST",
       cache: false,
       //data: form,
       processData:false,
       contentType:false,
       success: function(json) {
        $("#status").html("");
        window.location.reload();
         }
       });  
} 
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
												<td ><%= $wan_if%></td>
												<td><%= $ip_addr%></td>
												<td ><%= $run_time%></td>
									</tr>
									<tr>
												<td >WAN</td>
												<td><%= `ubus call network.interface.wan status |grep "\"address\":" |head -n 1 |cut -d: -f2 |tr -d "\"\, "` %></td>
												<td><%= `ubus call network.interface.wan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "` %></td>
										</tr>
                    <%
                    if [ "`ifconfig wlan0 |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
										echo "<td >WWAN</td>"
										echo "<td>"
                    ubus call network.interface.wwan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td><td>"
                    ubus call network.interface.wwan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td></tr>"
                    fi
                    %>
                    <%
                    if [ "`ubus call network.interface.4g status |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
										echo "<td >4G</td>"
										echo "<td>"
                    ubus call network.interface.4g status |grep "\"address\":" |head -n 1 |cut -d: -f2 |tr -d "\"\, "
                    echo "</td><td>"
                    ubus call network.interface.4g status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td></tr>"
                    fi
                    %>
                    <%
                    if [ "`ifconfig pptp-pptp |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
                    echo "<td >PPTP</td>"
                    echo "<td>"
                    ubus call network.interface.pptp status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td><td>"
                    ubus call network.interface.pptp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td></tr>"
                    fi
                    %>
                    <%
                    if [ "`ifconfig tun0 |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
                    echo "<td >TUN0</td>"
                    echo "<td>"
                    ifconfig tun0 |grep inet |cut -d: -f2 |cut -d" " -f1
                    echo "</td><td>"
                    echo "unkown"
                    echo "</td></tr>"
                    fi
                    %>
								</table>
					<div class="title"><%= $modem_info%></div>
						<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" >

										<tr>
												<td  width="20%" ><%= $g4_model%></td>
												<td colspan="3" ><%= `uci get 4g.modem.rev 2>/dev/null` %></td>
										</tr>
                    <tr>
												<td ><%= $sim_status%></td>
												<td colspan="3" id="sim"><%= `uci get 4g.modem.reg_net 2>/dev/null` %></td>
										</tr>
										<tr>
                        <td ><%= $sig%></td>
                        <%
             if uci get -q 4g.modem.rssi |grep '^[[:digit:]]*$' > /dev/null;then
                sig1=$((`uci get 4g.modem.rssi` * 100/31))
                  if [ $sig1 -gt 100  ];then
                  sig1=ERROR
                  else
                  sig1=$sig1%
                  fi
                else
                sig1=
              fi
                        %>
												<td colspan="3" id="sig"><%= $sig1 %></td>
                    </tr>
                    <tr>
												<td >IMEI</td>
												<td colspan="3" id="imei"><%= `uci get 4g.modem.imei 2>/dev/null` %></td>
                    </tr>
                    <tr>
												<td >IMSI</td>
												<td colspan="3" id="imsi"><%= `uci get 4g.modem.imsi 2>/dev/null` %></td>
                    </tr>
                    <tr>
												<td >ICCID</td>
												<td colspan="3" id="iccid"><%= `uci get 4g.modem.iccid 2>/dev/null` %></td>
										</tr>
										<!-- <tr>
												<td ><%= $used_byte%></td>
												<td id="used_byte"  colspan="2">                          
			<% g4byte=`uci get 4g.modem.4g_byte`
                          if [ $g4byte -ge 1000000000 ];then
                           g4byte=`awk -v x=$g4byte  'BEGIN{printf "%.2fGB",x/1024/1024/1024}'`
                          elif [ $g4byte -ge 1000000 ]; then
                           g4byte=`awk -v x=$g4byte  'BEGIN{printf "%.2fMB",x/1024/1024}'`
                          else
                           g4byte=`awk -v x=$g4byte   'BEGIN{printf "%dKB",x/1024}'`
                          fi %>
                          <%= $g4byte %></td>
                        </tr> -->
							</table>
              <br />
              <!-- <div class="btn-wrap">
              <div class="save-btn fr"><a href="javascript:clear_4g()"><%= $clear%></a></div>
            </div> -->
            <div ><p style="display:inline;color:#e81717;font-size:large;margin-left: 100px;" id="status"></p></div>
              <div class="btn-wrap">
              <div class="save-btn fr"><a  href="javascript:myrefresh()" class="myrefresh"><%= $refresh%></a></div>
            </div>
						</div>
				</div>
		</div>
</div>
</body>
</html>


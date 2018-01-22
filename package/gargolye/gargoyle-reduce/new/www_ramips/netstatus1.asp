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
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript">

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
												<td><%= `ubus call network.interface.wan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` %></td>
												<td><%= `ubus call network.interface.wan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "` %></td>
										</tr>
										<tr>
												<td >WWAN</td>
												<td><%= `ubus call network.interface.wwan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` %></td>
												<td><%= `ubus call network.interface.wwan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "` %></td>
										</tr>
										<tr>
												<td >4G</td>
												<td><%= `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` %></td>
												<td><%= `ubus call network.interface.4g status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "` %></td>
										</tr>
								</table>
					<div class="title"><%= $modem_info%></div>
						<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" >

										<tr>
												<td width="20%" ><%= $g4_model%></td>
												<td ><%= `uci get 4g.modem.rev 2>/dev/null` %></td>
										</tr>
										<tr>
												<td ><%= $sim_status%></td>
												<td colspan="3"><%= `uci get 4g.modem.sim_status 2>/dev/null` %></td>
										</tr>
										<tr>
												<td ><%= $sig%></td>
												<td colspan="3"><%= `uci get 4g.modem.rssi 2>/dev/null` %></td>
										</tr>
										<tr>
												<td ><%= $net_status%></td>
												<td colspan="3"><%= `uci get 4g.modem.reg_net 2>/dev/null` %></td>
										</tr>
																				<tr>
												<td >IMEI</td>
												<td colspan="3"><%= `uci get 4g.modem.imei 2>/dev/null` %></td>
										</tr>
										<tr>
												<td >IMSI</td>
												<td colspan="3"><%= `uci get 4g.modem.imsi 2>/dev/null` %></td>
										</tr>
										<tr>
												<td >ICCID</td>
												<td colspan="3"><%= `uci get 4g.modem.iccid 2>/dev/null` %></td>
										</tr>
										<tr>
												<td ><%= $used_byte%></td>
												<td colspan="3"><%= `uci get 4g.modem.4g_byte 2>/dev/null` %></td>
										</tr>
							</table>
						</div>
				</div>
		</div>
</div>
</body>
</html>

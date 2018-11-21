#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/baseinfo.po
. /etc/openwrt_release
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Main page</title>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript" src="jjs/jquery.js"></script>
    <script type="text/javascript">

     function show_sys(){
       $.ajax({
       url: "/cgi-bin/baseinfo.sh",
       type: "get",
       cache: false,
       //data: form, 
       processData:false,
       contentType:false,
       success: function(json) {
         $("#uptime").html(parseInt(json.uptime/86400) +" <%= $day%> "
         +parseInt(json.uptime%86400/3600)+" <%= $hour%> "
         +parseInt(json.uptime%3600/60)+" <%= $minute%> "
         +parseInt(json.uptime%60)+" <%= $sec%>");
         $("#loadavg").html(json.loadavg+"--(1,5,15 <%= $load_avg%>)");
         $("#time").html(json.time);
         }
       });
     }
     $(window).on('load', function () {
      setInterval(show_sys,1000);
        });
    </script>

</head>
<body>
<div class="current"><%= $location%></div>
<div class="wrap-main" style="position: relative;min-height: 100%">
		<div class="wrap">
				<div class="title"><%= $base_info%></div>
				<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" class="base-info">
								<tbody id="sysinfobody">
										<tr>
												<th width="20%"><%= $sys_ver%></th>
												<td><% uci get gargoyle.global.soft_ver %><%= $DISTRIB_BULDTIME %></td>
										</tr>
										<tr>
												<th width="20%"><%= $model%></th>
												<td><% uci get gargoyle.global.model_name %></td>
										</tr>
										<tr>
												<th width="20%"><%= $id%></th>
												<td><%= `dd bs=1 skip=46 count=6 if=/dev/mtd2 2>/dev/null | hexdump -v -n 6 -e '5/1 "%02x:" 1/1 "%02x"'|tr -d ":"` %></td>
										</tr>
										<tr>
												<th width="20%"><%= $mac%></th>
												<td><%= `dd bs=1 skip=46 count=6 if=/dev/mtd2 2>/dev/null | hexdump -v -n 6 -e '5/1 "%02x:" 1/1 "%02x"'|tr -d ":"` %></td>
										</tr>
										<tr>
												<th width="20%"><%= $run_time%></th>
												<td id="uptime" >
			<%  secs=`cut -d. -f1  /proc/uptime`  %>
                        <%= "$(($secs/86400)) $day $(($secs%86400/3600)) $hour $(($secs%3600/60)) $minute $(($secs%60)) $sec" %>
												</td>
										</tr>
										<tr>
												<th width="20%"><%= $sys_load%></th>
												<td id="loadavg"><%= `cat /proc/loadavg  | awk '{print $1",",$2",",$3}'` %>--(1,5,15 <%= $load_avg%>)</td>
										</tr>
										<tr>
												<th width="20%"><%= $sys_time%></th>
												<td id="time" ><%= `date` %></td>
										</tr>
						</table>

				</div>
		</div>


</div>
</body>
</html>

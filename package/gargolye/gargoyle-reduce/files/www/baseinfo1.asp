#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="refresh" content="5">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Main page</title>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript">

    </script>

</head>
<body>
<div class="current">当前位置：首页 > 基本信息</div>
<div class="wrap-main" style="position: relative;min-height: 100%">
		<div class="wrap">
				<div class="title">基本信息</div>
				<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" class="base-info">
								<tbody id="sysinfobody">
										<tr>
												<th width="20%">系统版本</th>
												<td><%= `cat /www/data/version.txt` %></td>
										</tr>
										<tr>
												<th width="20%">设备型号</th>
												<td><%= `cat /proc/cpuinfo |grep machine |cut -d: -f2` %></td>
										</tr>
										<tr>
												<th width="20%">序列号</th>
												<td><%= `dd bs=1 skip=46 count=6 if=/dev/mtd2 2>/dev/null | hexdump -v -n 6 -e '5/1 "%02x:" 1/1 "%02x"'|tr -d ":"` %></td>
										</tr>
										<tr>
												<th width="20%">MAC 地址</th>
												<td><%= `dd bs=1 skip=46 count=6 if=/dev/mtd2 2>/dev/null | hexdump -v -n 6 -e '5/1 "%02x:" 1/1 "%02x"'|tr -d ":"` %></td>
										</tr>
										<tr>
												<th width="20%">运行时间</th>
												<td><%= `cut -d. -f1  /proc/uptime` %> 秒</td>
										</tr>
										<tr>
												<th width="20%">系统负载</th>
												<td><%= `cat /proc/loadavg  | awk '{print $1",",$2",",$3}'` %>--(1,5,15分钟平均负载)</td>
										</tr>
										<tr>
												<th width="20%">系统时间</th>
												<td><%= `date` %></td>
										</tr>
						</table>
						
				</div>
		</div>


</div>
</body>
</html>

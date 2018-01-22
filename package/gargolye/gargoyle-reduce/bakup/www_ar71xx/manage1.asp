#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>欢迎登录-路由器管理界面</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>

    <script type="text/javascript" src="jjs/jquery.js"></script>

    <script type="text/javascript" src="/jjs/plugin/iPath1/iPath.js"></script>
    <link rel="stylesheet" type="text/css" href="/jjs/plugin/iPath1/iPath.css" />

	<script type="text/javascript" src="jjs/main.js?_=1"></script>
	</head>
<body>
    <div class="layout">
        <div class="layout_title">
            <div class="logo"><img src="images/LOGO1.png"  /></div>
            <div class="sysname" style="display: none;">您的绑定码是：<%= `uci get 4g.server.sn |md5sum |awk '{print $1}'` %></div>
            <div class="systoolbar">
				<div><cite class="sys-icon quit-ico"></cite><a href="/logout.asp">退出</a></div>
			</div>
        </div>
        <div class="layout_left">
            <ul class="menu">
                <li style="display:none;">
                    <div class="menuname"><cite class="m-icon01 sys-icon"></cite><a class="home" target="main_frame" href="/baseinfo1.asp">首页</a></div>

                </li>
                <li>
                    <div class="menuname"><cite class="m-icon01 sys-icon"></cite><a class="home" target="main_frame" href="/baseinfo1.asp">首页</a></div>
                </li>
				 <li>
                    <div class="menuname"><cite class="m-icon02 sys-icon"></cite>系统状态</div>
                    <div class="children">
                        <ul>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/apinfo1.asp">客户端信息</a></div>
                            </li>

							 <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/statics1.asp">流量统计</a></div>
                            </li>
							 <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/netstatus1.asp">4G/WAN状态</a></div>
                            </li>
                        </ul>
                    </div>
                </li>
                <li>
                    <div class="menuname"><cite class="m-icon03 sys-icon"></cite>无线设置</div>
                    <div class="children">
                        <ul>
                            <li>
                            <div class="menuname">
                            <a target="main_frame" href="/wifisetting1.asp">2.4G基本设置</a></div>
                            </li>

							              <li>
                                <div class="menuname">
                                <a target="main_frame" href="/wifirepeater1.asp">2.4G无线中继</a></div>
                            </li>

                        </ul>
                    </div>
                </li>
				 <li>
                    <div class="menuname"><cite class="m-icon05 sys-icon"></cite>网络设置</div>
                    <div class="children">
                        <ul>
														<li>
																<div class="menuname">
																		<a target="main_frame" href="/4g1.asp">4G设置</a></div>
														</li>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/wan1.asp">WAN口设置</a></div>
                            </li>
                             <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/lan1.asp">LAN口设置</a></div>
                            </li>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/dhcp1.asp">DHCP设置</a></div>
                            </li>
                        </ul>
                    </div>
                </li>
				 <li>
                    <div class="menuname"><cite class="m-icon07 sys-icon"></cite>系统维护</div>
                    <div class="children">
                        <ul>

 <!--                           <li>
                                <div class="menuname">
                                    <a target="main_frame" href="index.htm?PAGE=apmode">AP模式</a></div>
                            </li>
 -->
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/passwd1.asp">Web访问管理</a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/backup1.asp">备份/恢复</a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/upgradefirm1.asp">固件升级</a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/time1.asp">系统时间</a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/reboot1.asp">重新启动</a></div>
                            </li>
                        </ul>
                    </div>
                </li>

            </ul>
        </div>
        <div class="layout_main">
            <div class="main_frame">
                <iframe id="main_frame" name="main_frame" frameborder="no" border="0" marginwidth="0" marginheight="0"
                        src="/baseinfo1.asp"></iframe>
            </div>
        </div>
    </div>
	<script type="text/javascript" src="jjs/menu.js"></script>
	<div class="footer" style="position: absolute;bottom: 1px;right: 100px;" >
		<span class="f_titer" style="font-size: 20px;">Copyright © 2017 Shenzhen LINK-4ALL Technology Co., Ltd</span>
	</div>
</body>
</html>

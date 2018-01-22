#!/usr/bin/haserl
<%
  valid=$( eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time" ) | grep "Set-Cookie" )

	if [ -n "$valid" ] ; then
			echo "Status: 302 Found"
  		echo "Location: /manage1.asp"
			echo ""
		  echo ""
		  exit
	fi
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>欢迎登录-路由器管理界面</title>
	<link rel="stylesheet" type="text/css" href="css/global.css"/>
	<link rel="stylesheet" type="text/css" href="css/layout.css"/>
	<link rel="stylesheet" type="text/css" href="css/login.css"/>
    <script type="text/javascript" src="/jjs/jquery.js"></script>
     <script type="text/javascript" src="/jjs/common.js"></script>
     <script type="text/javascript" src="/jjs/login.js"></script>
    <style type="text/css">
        .error-message {
            display: none;
        }
        .login-name{
        display: none;
        }
    </style>
    <script type="text/javascript">
    //解决login1.asp只在iframe内显示问题
    if (window != top)
    top.location.href = location.href;
    </script>
</head>
<body>
<div class="login-bg">
		<div class="login-con">
				<div class="sys-logo"><img src="images/LOGO1.png" /></div>
				<div class="login-wrap">
						<div class="login-title">登录</div>
						<div class="error-message"><cite class="tip-ico text-c"></cite><cite>密码输入错误，请重新输入</cite></div>
						<ul class="login-form">
								<li class="login-name"><cite class="sys-icon user-ico fl"></cite><div class="fl"><input id="usr" type="text" /></div> </li>
								<li class="login-pass"><cite class="sys-icon pass-ico fl"></cite><div class="fl"><input id="pwd" type="password" /></div></li>
						</ul>
						<div class="login-btn"><a href="javascript:doLogin()">登录</a></div>
				</div>
		</div>
</div>
</body>
</html>

<script>
document.getElementById('pwd').focus();
</script>

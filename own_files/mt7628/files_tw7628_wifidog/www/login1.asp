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
  lang=`uci get gargoyle.global.lang`
  . /www/data/lang/$lang/login.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%= $welcome_greeting %></title>
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
        .sysname{
                float: right;
                margin: 10px 30px 0 20px;/*修改*/
                vertical-align: text-top;
                font-size: 15px;
                line-height: 28px;
                color: #630d0d;
            }
    </style>
    <script type="text/javascript">
    //解决login1.asp只在iframe内显示问题
    if (window != top)
    top.location.href = location.href;
    function change_lang(){
        var form = new FormData(document.getElementById("form0"));
             $.ajax({
            url: "/cgi-bin/setlang.sh",
            type: "POST",
            data:form, 
            processData:false,
            contentType:false,
           // contentType: "application/json; charset=utf-8",
            success: function(json) {
  					 window.location.reload();
            },
            error: function(error) {
              //alert("调用出错" + error.responseText);
            }
          });
    }
    </script>
</head>
<body>
<div class="login-bg">
		<div class="login-con">
				<div class="sys-logo"><img src="images/LOGO1.png" /></div>
				<div class="login-wrap">
          <div class="sysname"><span>Language(语言)：</span>
            <form id="form0" style='display:inline;' >
             <select class="lang" name="lang" onchange="change_lang()">
             <option value="zh_cn" <% [ `uci get gargoyle.global.lang |grep "zh_cn"` ] && echo 'selected="true"' %> >中文</option>
             <option value="en_us" <% [ `uci get gargoyle.global.lang |grep "en_us"` ] && echo 'selected="true"' %> >English</option>
             <option value="esp" <% [ `uci get gargoyle.global.lang |grep "esp"` ] && echo 'selected="true"' %> >Español</option>
             </select>
         </form>
      </div>
						<div class="login-title"><%= $login%></div>
						<div class="error-message"><cite class="tip-ico text-c"></cite><cite><%= $login_tip%></cite></div>
						<ul class="login-form">
								<li class="login-name"><cite class="sys-icon user-ico fl"></cite><div class="fl"><input id="usr" type="text" /></div> </li>
								<li class="login-pass"><cite class="sys-icon pass-ico fl"></cite><div class="fl"><input id="pwd" type="password" /></div></li>
            </ul>
						<div class="login-btn"><a href="javascript:doLogin()"><%= $login%></a></div>
				</div>
		</div>
</div>
</body>
</html>

<script>
document.getElementById('pwd').focus();
</script>

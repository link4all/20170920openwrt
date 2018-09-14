#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/manage.po
company_name=`uci get gargoyle.global.company_${lang}`
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%= $welcome_greeting %></title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>

    <script type="text/javascript" src="jjs/jquery.js"></script>

    <script type="text/javascript" src="/jjs/plugin/iPath1/iPath.js"></script>
    <link rel="stylesheet" type="text/css" href="/jjs/plugin/iPath1/iPath.css" />

	<script type="text/javascript" src="jjs/main.js"></script>
	<script type="text/javascript">
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

  function get4ginfo(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/get4ginfo.sh?sigonly=1",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {         
            var sigimg=document.getElementById('sigimg'); 
            var rssi=parseInt(json.sig);
            if(rssi<=31 && rssi>24){  
              sigimg.src="/images/sig4.png";
            }
            else if(rssi<=24 && rssi>17){  
           sigimg.src="/images/sig3.png";
            } 
            else if(rssi<=17 && rssi>10){  
           sigimg.src="/images/sig2.png";
            } 
            else if(rssi<=10 && rssi>0){  
           sigimg.src="/images/sig1.png";
            } 
           else{  
             sigimg.src="/images/sig_no_sim.png";
            } 
            //sig.innerHTML=json.sig 
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
	  $(window).on('load', function () {
        setInterval(get4ginfo,10000);
      });

    </script>
	</head>
<body>
    <div class="layout">
        <div class="layout_title">
            <div class="logo"><h1>&nbsp;&nbsp;<font color="white" face="arial">4G WIFI ROUTER</font></h1></div>
            <div class="systoolbar">
						  <div><cite class="sys-icon quit-ico"></cite><a href="/logout.asp"><%= $logout %></a></div>
                  </div>

						<div class="sysname"><img id="sigimg" src="" style="float:left;padding-right:20px;" /><span>Language(语言)：</span>
							<form id="form0" style='display:inline;' >
							 <select class="lang" name="lang" onchange="change_lang()">
							 <option value="zh_cn" <% [ `uci get gargoyle.global.lang |grep "zh_cn"` ] && echo 'selected="true"' %> >中文</option>
							 <option value="en_us" <% [ `uci get gargoyle.global.lang |grep "en_us"` ] && echo 'selected="true"' %> >English</option>
							 </select>
					 </form>
				</div>
        </div>
        <div class="layout_left">
            <ul class="menu">
                <li>
                    <div class="menuname"><cite class="m-icon01 sys-icon"></cite><a class="home" target="main_frame" href="/baseinfo1.asp"><%= $home %></a></div>
                </li>
				 <li>
                    <div class="menuname"><cite class="m-icon02 sys-icon"></cite><%= $sysinfo %></div>
                    <div class="children">
                        <ul>
                                <li>
                                        <div class="menuname">
                                            <a target="main_frame" href="/baseinfo1.asp"><%= $baseinfo %></a></div>
                                    </li>
                                <li>
                                        <div class="menuname">
                                            <a target="main_frame" href="/netstatus1.asp"><%= $wan_status %></a></div>
                                    </li>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/apinfo1.asp"><%= $clientinfo %></a></div>
                            </li>

							 <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/statics1.asp"><%= $statistics %></a></div>
                            </li>

                        </ul>
                    </div>
                </li>
                <li>
                    <div class="menuname"><cite class="m-icon03 sys-icon"></cite><%= $wireless_setting %></div>
                    <div class="children">
                        <ul>
                            <li>
                            <div class="menuname">
                            <a target="main_frame" href="/wifisetting1.asp"><%= $w2_basic %></a></div>
                            </li>

							              <li>
                                <div class="menuname">
                                <a target="main_frame" href="/wifirepeater1.asp"><%= $w2_repeater %></a></div>
                            </li>

                        </ul>
                    </div>
                </li>
				 <li>
                    <div class="menuname"><cite class="m-icon05 sys-icon"></cite><%= $network_setting%></div>
                    <div class="children">
                        <ul>
                            <li>
                                    <div class="menuname">
                                            <a target="main_frame" href="/4g1.asp"><%= $g4_setting %></a></div>
                            </li>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/wan1.asp"><%= $wan_setting%></a></div>
                            </li>
                             <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/lan1.asp"><%= $lan_setting%></a></div>
                            </li>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/dhcp1.asp"><%= $dhcp_setting%></a></div>
                            </li>
                            <li>
                                    <div class="menuname">
                                            <a target="main_frame" href="/macfilter1.asp"><%= $macfilter_setting %></a></div>
                            </li>
                            <li>
                                <div class="menuname">
                                        <a target="main_frame" href="/route1.asp"><%= $st_route %></a></div>
                        </li>
                        </ul>
                    </div>
                </li>
				 <li>
                    <div class="menuname"><cite class="m-icon07 sys-icon"></cite><%= $admin%></div>
                    <div class="children">
                        <ul>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/passwd1.asp"><%= $web_access%></a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/backup1.asp"><%= $bak_restore%></a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/upgradefirm1.asp"><%= $upgrade%></a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/time1.asp"><%= $time_setting%></a></div>
                            </li>
                            <li>
                                <div class="menuname">
                                    <a target="main_frame" href="/dmesg1.asp"><%= $syslog%></a></div>
                            </li>
							<li>
                                <div class="menuname">
                                    <a target="main_frame" href="/reboot1.asp"><%= $reboot%></a></div>
                            </li>
                        </ul>
                    </div>
		<div class="menuname"><cite class="m-icon08 sys-icon"></cite><%= $advance%></div>
			<div class="children">
			<ul>
               <li>
                      <div class="menuname">
                      <a target="main_frame" href="/vpn1.asp"><%= $vpn_setting%></a></div>
               </li>
				<li>
				<div class="menuname">
				<a target="main_frame" href="/dtu1.asp"><%= $dtu%></a></div>
                </li>
                <li>
                    <div class="menuname">
                    <a target="main_frame" href="/dmz1.asp"><%= $dmz_setting%></a></div>
                    </li>
                    <li>
                        <div class="menuname">
                        <a target="main_frame" href="/phddns1.asp"><%= $oray%></a></div>
                        </li>
                        <li>
                                <div class="menuname">
                                        <a target="main_frame" href="/portmap1.asp"><%= $portmap %></a></div>
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
		<span class="f_titer" style="font-size: 20px;">Copyright © 2009-2018 <%= $company_name%> </span>
	</div>
</body>
</html>


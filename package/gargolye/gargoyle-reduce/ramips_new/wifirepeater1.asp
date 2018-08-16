<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/wifirepeater.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript" src="jjs/jquery.js"></script>	
<link rel="stylesheet" type="text/css" href="css/form.css" />
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />

  <script type="text/javascript">
        function apscan(){
         // document.getElementById("form0").submit();
         $("#aplist").html("");//扫描前先清空
          $("#status").html("正在扫描AP,请等待！");
          $.ajax({
          url: "/cgi-bin/apscan.sh",
          type: "get",
          dataType:"json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
            for (var key in json) {
            var tbody="";
              tbody += '<tr><td>'+key
                    + '</td><td>'+json[key].chanel
                    + '</td><td>'+json[key].bssid
                    + '</td><td>'+json[key].security
                    + '</td><td>'+json[key].signal
                    + '</td><td width="80px"><input class="green-btn" type="button" onclick="selrepeater(this)" value="选择"/></td></tr>';  
              $("#aplist").append(tbody);  
               }       
             $("#status").html("<%= $finish_scan%>");
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
	  $(window).on('load', function () {
     checkip()
      });
  function selrepeater(obj){
   document.documentElement.scrollTop=document.body.scrollTop =0;//回到顶部
   var    ssid1=$(obj).parent().parent().find("td").eq(0).text();
   var channel1=$(obj).parent().parent().find("td").eq(1).text();
   var   etype1=$(obj).parent().parent().find("td").eq(3).text();
   document.getElementById("ssid").value=ssid1;
   document.getElementById("channel").value=channel1;
   document.getElementById("etype").value=etype1;
   document.getElementById("pass").value="";
   document.getElementById('pass').focus();
    $("#status").html("<%= $selected%>SSID:\""+ssid1+"\",<%= $input_pass%>");
   }
  function checkip(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/checkip.sh",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
            if ( json["ip"].length==0 ){
           $("#wwanip")[0].value="<%= $no_conn%>" 
           }
           else{
            $("#wwanip")[0].value="<%= $conn%>"+ json["ip"] 
           }           
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    }
    
    function showpasswd(){
      var pass=document.getElementById("pass")
      if (pass.type=="password"){
         pass.type="text"
         document.getElementById("dispass").value="<%= $hide_pass%>"
         }
        else{
         pass.type="password"  
        document.getElementById("dispass").value="<%= $show_pass%>"
        }
     }
     
     function setrepeater(){
      $("#status").html("<%= $processing%>");
      var form = new FormData(document.getElementById("form0"));
       $.ajax({
          type: "post", 
          url: "/cgi-bin/setmtkrepeater.sh",
          data:form, 
          processData:false,
          contentType:false,
          success: function(json) {
           $("#status").html("<%= $finish%>");
            document.documentElement.scrollTop=document.body.scrollTop =0;//回到顶部
            setTimeout("checkip()",5000);
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
          
     }
    </script>
</head>
<body>
    <div class="current"><%= $location%></div> 
      <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $page%><p style="display:inline;color:#e81717;font-size:16px;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
                <form class="form-info" id="form0" >
		     <label>
                                    <div class="name"><%= $enable_repeater%>:</div>
                                    <div>
                                        <input type="checkbox"  name="setrepeater" value="1" <% [ `uci get wireless.sta.disabled` = 1 ] || echo -n checked %> />
                                    </div>
                     </label>
                    <label>
                        <div class="name"><%= $conn_status%></div> 
                        <div>
                         <input name="wwanip" type="text" value="" id="wwanip" readonly="readonly" /> 
                        </div>
                    </label>
                   
                                   
             
                            <label>
                                <div class="name"><%= $pass%></div>
                                <div>
                                    <input id="pass" name="epwd" type="password"  value="" />
                                    <input id="dispass" class="green-btn" type="button" value="<%= $show_pass%>" onclick="showpasswd()"/>
                                </div>
                            </label>   
                                <input id="ssid" name="essid" type="hidden" value=""  />                    
                                <input id="etype" type="hidden" name="etype" value=""  />
                                <input id="channel" type="hidden" name="channel" />
                </form>
				  <div class="btn-wrap">
					    <div class="save-btn fr"><a href="javascript:setrepeater()"><%= $save%></a></div>
					     <input type="button" class="green-btn" onclick="apscan()" value="<%= $scan%>" />
					</div>
            </div>
        </div>
    	<div class="wrap" style="margin-top:-50px;">
            <div class="wrap-table">
                <table border="0" cellspacing="0" cellpadding="0" class="table-con">
                    <thead>
                        <th width="20%">SSID</th>
                        <th width="5%"><%= $ch%></th>
                        <th width="20%"><%= ap_mac%></th>
                        <th width="20%"><%= $enc%></th>
                        <th width="15%"><%= $sig%></th>
                        <th width="20%"><%= $sel%></th>
                    </thead>
                    <tbody id="aplist">

                    </tbody>
                </table>
            </div>
        </div>
    </div>
  
</body>
</html>

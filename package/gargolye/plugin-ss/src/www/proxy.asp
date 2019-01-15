<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/proxy.po 
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
  <script type="text/javascript">
  function set_ser2net(){
        $("#status").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/proxy.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("<%= $error%>");
             }else{
                $("#status").html("<%= $finish%>"+json.stat);
             }
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
            <div class="title"><%= $page%><p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">
               <label>
                   <div class="name"></div>
                   <div>
                       <input type="checkbox"  value="1" name="mptcp" <% [ `uci get shadowsocks-libev.hi.disabled` = 0 ]  && echo checked %>/><%= $enable%><%= $server%>
                   </div>
               </label>
               <div id="mask">
                    <label >
                        <div class="name"><%= $server%>：</div>
                        <div>
                            <input  name="server" type="text" value="<% uci get shadowsocks-libev.sss0.server %>" />
                        </div>
                    </label>
                    <label >
                        <div class="name"><%= $port%>：</div>
                        <div>
                            <input  name="port" type="text" value="<% uci get shadowsocks-libev.sss0.server_port %>" />
                        </div>
                    </label>
                    <label >
                        <div class="name"><%= $method%>：</div>
                        <div>
                            <input  name="method" type="text" value="<% uci get shadowsocks-libev.sss0.method %>" />
                        </div>
                    </label>
                    <label >
                        <div class="name"><%= $passwd%>：</div>
                        <div>
                            <input  name="passwd" type="text" value="<% uci get shadowsocks-libev.sss0.password %>" />
                        </div>
                    </label>
                    <label >
                        <div class="name">obfs：</div>
                        <div>
                            <input  name="obfs" type="text" value="<% uci get shadowsocks-libev.hi.obfs %>" />
                        </div>
                    </label>
              </div>
                </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:set_ser2net()"><%= $save%></a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>


<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/dhcp.po
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
  function setdhcp(){
        $("#status").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/setdhcp.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("<%= $dhcp_error%>");
             }else{
                $("#status").html("<%= $finish_dhcp%>");
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
                            <input type="checkbox" value="1" name="dhcpenable" <%  [ `uci get dhcp.lan.ignore` -eq 1 ] ||  echo 'checked' %>/><%= $open%> DHCP
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $start%> IP：</div>
                        <div>
                            <input id="startip" name="startip" type="text" placeholder="100" value="<% uci get dhcp.lan.start %>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $limit%>：</div>
                        <div>
                            <input id="limit" name="limit" type="text" placeholder="150" value="<% uci get dhcp.lan.limit %>" />
                        </div>
                    </label>
                   <label class="">
                        <div class="name"><%= $leasetime%>：</div>
                        <div>
                            <input id="leasetime" name="leasetime" type="text" placeholder="12h" value="<% uci get dhcp.lan.leasetime %>" />
                        </div>
                    </label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:setdhcp()">保存</a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>

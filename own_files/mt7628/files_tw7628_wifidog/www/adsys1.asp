<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/adsys.po
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
  function set_adsys(){
        $("#status").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/adsys.sh",
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
               <label >
                   <div class="name"><%= $enable%>：</div>
                   <div>
                       <input  name="enable" type="checkbox" value="1" <% [ `uci get wifidog.@wifidog[0].enable ` = "1" ] && echo checked %>" />
                   </div>
               </label>
                    <label >
                        <div class="name"><%= $reauth_time%>：</div>
                        <div>
                            <input  name="timeout" type="text" value="<%  uci get wifidog.@wifidog[0].client_timeout %>" />
                        </div>
                    </label>
                    <label >
                        <div class="name">Wait Time(Sec)：</div>
                        <div>
                            <input  name="wait_time" type="text" value="<%  uci get wifidog.@wifidog[0].wait_time %>" />
                        </div>
                    </label>
                    <label >
                        <div class="name"><%= $redirecturl%>：</div>
                        <div>
                            <input  name="redirurl" type="text" value="<%  uci get wifidogauth.auth.redirect_url %>" />
                        </div>
                    </label>
<!--                    <label >
                        <div class="name"><%= $allow%>：</div>
                        <div>
<textarea  name="allow"   rows="4" cols="50" >
<% for i in `uci get nodogsplash.@nodogsplash[0].allow_site`
do
echo -en "$i\n"
done
%>
</textarea>
                        </div>
                    </label> -->
                    <label >
                        <div class="name"><%= $forbid%>：</div>
                        <div>
<textarea  name="forbid"   rows="8" cols="50" >
<% for i in `uci get dhcp.@dnsmasq[0].address`
do
echo $i |awk -F '\/' '{print $2}'
done
%>
</textarea>
                        </div>
                    </label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:set_adsys()"><%= $save%></a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>

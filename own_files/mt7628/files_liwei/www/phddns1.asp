<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/phddns.po
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
  function setlan(){
        $("#status").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/phddns.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.status==undefined){
             $("#status").html("<%= $phddns_error%>");
             }else{
                $("#status").html("<%= $finish_phddns%>");
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
                                <input type="checkbox" value="1" name="enable" <% [ `uci get  phddns.@phddns[0].enabled` = 1 ] && echo checked %>/><%= $enable_ddns %>
                            </div>
                        </label>
                        <label class="">
                            <div class="name"><%= $provider%>：</div>
                            <div>
                                    <select name="ddns_provider" >
                                            <option value="oray.com" <% [ `uci -q get phddns.@phddns[0].provider |grep "oray.com"` ] && echo -n 'selected="true"'%> >oray.com</option>
                                              <option value="3322.org" <% [ `uci -q get phddns.@phddns[0].provider |grep "3322.org"` ] && echo -n 'selected="true"'%> >3322.org</option>
                                              <option value="cloudflare.com-v1" <% [ `uci -q get phddns.@phddns[0].provider |grep "cloudflare.com-v1"` ] && echo -n 'selected="true"'%> >cloudflare.com-v1</option>
                                              <option value="core-networks.de" <% [ `uci -q get phddns.@phddns[0].provider |grep "core-networks.de"` ] && echo -n 'selected="true"'%> >core-networks.de</option>
                                              <option value="ddns.com.br" <% [ `uci -q get phddns.@phddns[0].provider |grep "ddns.com.br"` ] && echo -n 'selected="true"'%> >ddns.com.br</option>
                                              <option value="dnsdynamic.org"<% [ `uci -q get phddns.@phddns[0].provider |grep "dnsdynamic.org"` ] && echo -n 'selected="true"'%> >dnsdynamic.org</option>
                                              <option value="dnsexit.com" <% [ `uci -q get phddns.@phddns[0].provider |grep "dnsexit.com"` ] && echo -n 'selected="true"'%> >dnsexit.com</option>
                                              <option value="dnshome.de" <% [ `uci -q get phddns.@phddns[0].provider |grep "dnshome.de"` ] && echo -n 'selected="true"'%> >dnshome.de</option>
                                              <option value="dynsip.org" <% [ `uci -q get phddns.@phddns[0].provider |grep "dynsip.org"` ] && echo -n 'selected="true"'%> >dynsip.org</option> 
                                              <option value="no-ip.com" <% [ `uci -q get phddns.@phddns[0].provider |grep "no-ip.com"` ] && echo -n 'selected="true"'%> >no-ip.com</option> 
                                              <option value="dyndns.org" <% [ `uci -q get phddns.@phddns[0].provider |grep "dyndns.org"` ] && echo -n 'selected="true"'%> >dyndns.org</option>          
                                    </select>
                            </div>
                        </label>
                    <label class="">
                        <div class="name"><%= $user%>：</div>
                        <div>
                            <input id="ddnsuser" name="ddnsuser" type="text" value="<% uci get phddns.@phddns[0].username %>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"> <%= $passwd%>：</div>
                        <div>
                            <input id="ddnspass" name="ddnspass" type="text" value="<% uci get phddns.@phddns[0].password %>" />

                        </div>
                    </label>
             </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:setlan()"><%= $save%></a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>

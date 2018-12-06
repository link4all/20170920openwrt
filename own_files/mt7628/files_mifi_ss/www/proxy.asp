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
          url: "/cgi-bin/mpserver.sh",
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
        function mask_method(){
        var mpserv=$('input[name="mptcp"]:checked').val();
            if (mpserv==1){
              $("#mask").show();
              $("#mask1").hide();

            }
            else{
              $("#mask").hide();
              $("#mask1").show();
            }
        }

        $(window).on('load', function () {
        mask_method();
        });

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
                       <input type="checkbox" onclick="mask_method()" value="1" name="mptcp" <% [ `uci get shadowsocks-libev.hi.disabled` = 0 ]  && echo checked %>/><%= $enable%><%= $server%>
                   </div>
               </label>
               <div id="mask">
                 <label >
                     <div class="name"><%= $wan_sel%>：</div>
                     <div>
                         4g1<input type="checkbox"  value="1" name="m_wan1" <% [ `uci get network.wan1.multipath` = on ]  && echo checked %>/>
                         4g2<input type="checkbox"  value="1" name="m_wan2" <% [ `uci get network.wan2.multipath` = on ]  && echo checked %>/>
                         4g3<input type="checkbox"  value="1" name="m_wan3" <% [ `uci get network.wan3.multipath` = on ]  && echo checked %>/>
                         4g4<input type="checkbox"  value="1" name="m_wan4" <% [ `uci get network.wan4.multipath` = on ]  && echo checked %>/>
                         wan<input type="checkbox"  value="1" name="m_wan" <% [ `uci get network.wan.multipath` = on ]  && echo checked %>/>
                         wwan<input type="checkbox"  value="1" name="m_wwan" <% [ `uci get network.wwan.multipath` = on ]  && echo checked %>/>
                     </div>
                 </label>
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
              </div>
              <div id="mask1">
                <label >
                    <div class="name"><%= $interface%>：</div>
                    <div>
                      <select name="interface" >
                        <option value="wan1" <% [ `uci get gargoyle.global.master` = "wan1" ] && echo 'selected="true"' %>>4G 1</option>
                        <option value="wan2" <% [ `uci get gargoyle.global.master` = "wan2" ] && echo 'selected="true"' %>>4G 2</option>
                        <option value="wan3" <% [ `uci get gargoyle.global.master` = "wan3" ] && echo 'selected="true"' %>>4G 3</option>
                        <option value="wan4" <% [ `uci get gargoyle.global.master` = "wan4" ] && echo 'selected="true"' %>>4G 4</option>
                        <option value="wan" <% [ `uci get gargoyle.global.master` = "wan" ] && echo 'selected="true"' %>>WAN</option>
                        <option value="wwan" <% [ `uci get gargoyle.global.master` = "wwan" ] && echo 'selected="true"' %>>WWAN</option>
                      </select>
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


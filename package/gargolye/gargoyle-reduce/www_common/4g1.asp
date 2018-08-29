<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/g4.po
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
        $("#status").html("<%= $g4setting_processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/set4g.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.ipaddr==undefined){
             $("#status").html("<%= $g4setting_error%>");
             }else{
                $("#status").html("<%= $g4ip%>"+json.ipaddr);
             }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }
        function mask_method(){
        var index=$('.apn option').index($('.apn option:selected'));
        if (index==2){
         $("#apn").html('<input id="apn" name="apn" type="text"  />');
         }
        }
   function mode_change(){
     var index=$('.dialmode option').index($('.dialmode option:selected'));
     if (index==0){
      $(".modem_dev").css('display','none');
      $(".auth_mode").css('display','inline-block');
      }
      if (index==1){
       $(".modem_dev").css('display','inline-block');
       $(".auth_mode").css('display','none');
       }
   }
   $(window).load(function() {
   mode_change();
   });
  </script>
</head>
<body>
    <div class="current"><%= $location%></div>
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $g4_setting%> <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">

                    <label class="">
                        <div class="name"><%= $ip_addr%></div>
                        <div>
                            <input id="4gip" name="4gip" type="text" value="<% [ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] && ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, " || echo "$g4_noip" %>" readonly="readonly" style="background-color:#eee" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $dialmode%>:</div>
                        <select class="dialmode" name="dialmode" onchange="mode_change()">
                          <option value="gobinet" <% [ `uci get network.4g.proto |grep "dhcp"` ] && echo 'selected="true"' %> >Gobinet</option>
                          <option value="pppd" <% [ `uci get network.4g.proto |grep "3g"` ] && echo 'selected="true"' %> >PPPD</option>
                        </select>
                    </label>
                    <label class="modem_dev">
                        <div class="name"><%= $modem_dev%></div>
                        <div>
                            <select class="device" name="device">
                                <%
                                for dev in `ls /dev/tty[U,A][S,C][B,M]*`
                                  do
                                    echo -n "<option value=\"$dev\" "
					if [ "`uci get network.4g.device`" = "$dev" ];then
                                         echo "selected="true">$dev</option>"
					else
			            	echo  ">$dev</option>"
					fi
                                  done
                                %>
                            </select>
                        </div>
                    </label>
                    <label class="at_dev">
                        <div class="name"><%= $at_dev%></div>
                        <div>
                            <select class="at" name="at">
                                <%
                                for dev in `ls /dev/tty[U,A][S,C][B,M]*`
                                  do
                                    echo -n "<option value=\"$dev\" "
					if [ "`uci get 4g.modem.device`" = "$dev" ];then
                                         echo "selected="true">$dev</option>"
					else
			            	echo  ">$dev</option>"
					fi
                                  done
                                %>
                            </select>
                        </div>
                    </label>

                    <label class="">
                        <div class="name"><%= $apn_setting%></div>
                        <div id="apn">
				<input class="apn" name="apn" type="text" value="<% uci get config4g.@4G[0].apn %>" placeholder="apn" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $dialnumber%>:</div>
                        <div>
                            <input id="dialnumber" name="dialnumber" type="text" value="<% uci get config4g.@4G[0].dialnumber %>" placeholder="*99#" />
                        </div>
                    </label>
                    <label class="auth_mode">
                        <div class="name"><%= $auth_mode%>:</div>
                          <select  name="auth_mode" >
                            <option value="0" <% [ `uci get config4g.@4G[0].auth |grep "0"` ] && echo 'selected="true"' %> >None</option>
                            <option value="1" <% [ `uci get config4g.@4G[0].auth |grep "1"` ] && echo 'selected="true"' %> >Pap</option>
                            <option value="2" <% [ `uci get config4g.@4G[0].auth |grep "2"` ] && echo 'selected="true"' %> >Chap</option>
                            <option value="3" <% [ `uci get config4g.@4G[0].auth |grep "3"` ] && echo 'selected="true"' %> >MsChapV2</option>
                          </select>
                    </label>
                    <label class="">
                        <div class="name"><%= $username%></div>
                        <div>
                            <input id="username" name="username" type="text" value="<% uci get config4g.@4G[0].user %>" placeholder="<%= $place_hold%>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $passwd%></div>
                        <div>
                            <input id="password" name="password" type="text" value="<% uci get config4g.@4G[0].password %>"  placeholder="<%= $place_hold%>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $pincode%></div>
                        <div>
                            <input id="pincode" name="pincode" type="text" value="<% uci get config4g.@4G[0].pincode %>" placeholder="<%= $place_hold%>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $metric%>：</div>
                        <div>
                            <input id="metric" name="metric" type="text" value="<% uci -q get network.4g.metric %>" placeholder="<%= $place_hold%>" />
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


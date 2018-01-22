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
                            <input id="4gip" name="4gip" type="text" value="<% [ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] || echo "$g4_noip" %>" readonly="readonly" style="background-color:#eee" />
                        </div>
                    </label>
                    <label class="">
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
                    <label class="">
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
              <select class="apn" name="apn" onchange="mask_method()">
								<option value="3gnet" <% [ `uci get network.4g.apn |grep "3gnet"` ] && echo 'selected="true"' %> ><%= $g3net%></option>
								<option value="ctnet" <% [ `uci get network.4g.apn |grep "ctnet"` ] && echo 'selected="true"' %> ><%= $ctnet%></option>
								<option value=""  ><%= $custom%></option>
							</select>
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $username%></div>
                        <div>
                            <input id="username" name="username" type="text" value="<% uci get network.4g.username %>" placeholder="<%= $place_hold%>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $passwd%></div>
                        <div>
                            <input id="password" name="password" type="text" value="<% uci get network.4g.password %>"  placeholder="<%= $place_hold%><%= $place_hold%>" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name"><%= $pincode%></div>
                        <div>
                            <input id="pincode" name="pincode" type="text" value="<% uci get network.4g.pincode %>" placeholder="<%= $place_hold%>" />
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

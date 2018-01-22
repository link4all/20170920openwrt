<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/dtu.po
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
          url: "/cgi-bin/dtu.sh",
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
        var index=$('.mask option').index($('.mask option:selected'));
        if (index==6){
         $("#mask").html('<input id="mask" name="mask" type="text"  />');
         $("#mask input").focus();
         }
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
                        <div class="name">TCP <%= $port%>：</div>
                        <div>
                            <input  name="port" type="text" value="<% uci get ser2net.@proxy[0].tcpport %>" />
                        </div>
                    </label>
            <label >
              <div class="name"><%= $state%>：</div>
              <select  name="state" >
								<option value="raw" <% [ "`uci get ser2net.@proxy[0].state`" = "raw" ] && echo 'selected="true"' %> >raw</option>
								<option value="rawlp" <% [ "`uci get ser2net.@proxy[0].state`" = "rawlp"  ] && echo 'selected="true"' %> >rawlp</option>
								<option value="telnet" <% [ "`uci get ser2net.@proxy[0].state`" = "telnet"  ] && echo 'selected="true"' %> >telnet</option>
								<option value="off" <% [ "`uci get ser2net.@proxy[0].state`" = "off"  ] && echo 'selected="true"' %>  >off</option>
							</select>
              </label>
                    <label >
                        <div class="name"><%= $timeout%>：</div>
                        <div>
                            <input  name="timeout" type="text" value="<% uci get ser2net.@proxy[0].timeout %>" placeholder="0" />
                        </div>
                    </label>
                    <label >
                        <div class="name"><%= $device%>：</div>
                        <div>
                            <input  name="device" type="text" value="<% uci get ser2net.@proxy[0].device %>" placeholder="/dev/ttyS1" />
                        </div>
                    </label>
                    <label class="">
                      <div class="name"><%= $baudrate%>：</div>
                        <div id="mask">
                      <select name="mask"  class="mask"  onchange="mask_method()" >
                        <option value="9600" <% [ "`uci get ser2net.@proxy[0].baudrate`" = "9600" ] && echo 'selected="true"' %> >9600</option>
                        <option value="14400" <% [ "`uci get ser2net.@proxy[0].baudrate`" = "14400"  ] && echo 'selected="true"' %> >14400</option>
                        <option value="19200" <% [ "`uci get ser2net.@proxy[0].baudrate`" = "19200"  ] && echo 'selected="true"' %> >19200</option>
                        <option value="38400" <% [ "`uci get ser2net.@proxy[0].baudrate`" = "38400"  ] && echo 'selected="true"' %>  >38400</option>
                        <option value="57600" <% [ "`uci get ser2net.@proxy[0].baudrate`" = "57600"  ] && echo 'selected="true"' %>  >57600</option>
                        <option value="115200" <% [ "`uci get ser2net.@proxy[0].baudrate`" = "115200"  ] && echo 'selected="true"' %>  >115200</option>
                        <option value="" ><%= $custom%></option>
                      </select>
                      </div>
                    </label>
            <label >
              <div class="name"> <%= $parity%>：</div>
              <select  name="parity" >
                <option value="NONE" <% [ "`uci get ser2net.@proxy[0].parity_check`" = "NONE" ] && echo 'selected="true"' %> >None</option>
								<option value="ODD" <% [ "`uci get ser2net.@proxy[0].parity_check`" = "ODD"  ] && echo 'selected="true"' %> >Odd</option>
								<option value="EVEN" <% [ "`uci get ser2net.@proxy[0].parity_check`" = "EVEN"  ] && echo 'selected="true"' %> >Even</option>
              </select>
							</label>
              <label >
                <div class="name"> <%= $stopbit%>：</div>
                <select  name="stopbit" >
                  <option value="1STOPBIT" <% [ "`uci get ser2net.@proxy[0].stopbit`" = "1STOPBIT" ] && echo 'selected="true"' %> >1STOPBIT</option>
  								<option value="2STOPBIT" <% [ "`uci get ser2net.@proxy[0].stopbit`" = "2STOPBITS"  ] && echo 'selected="true"' %> >2STOPBITS</option>
                </select>
  							</label>
                <label >
                  <div class="name"> <%= $databit%>：</div>
                  <select  name="databit" >
                    <option value="7DATABITS" <% [ "`uci get ser2net.@proxy[0].databit`" = "7DATABITS" ] && echo 'selected="true"' %> >78DATABITS</option>
    								<option value="8DATABITS" <% [ "`uci get ser2net.@proxy[0].databit`" = "8DATABITS"  ] && echo 'selected="true"' %> >8DATABITS</option>
                  </select>
    							</label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:set_ser2net()"><%= $save%></a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>

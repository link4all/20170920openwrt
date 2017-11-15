<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
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
        $("#status").html("正在设置4G....请等待网络重启！");
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
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("已设置4G ip为:"+json.ipaddr);
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
    <div class="current">当前位置：网络设置 > 4G设置</div>
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title">4G设置 <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">

                    <label class="">
                        <div class="name">IP 地址：</div>
                        <div>
                            <input id="4gip" name="4gip" type="text" value="<% [ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] || echo "拨号未成功，请重试！" %>" readonly="readonly" style="background-color:#eee" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name">选择设备：</div>
                        <div>
                            <select class="device" name="device">
                                <%
                                for dev in `ls /dev/tty[U,A][S,C][B,M]*`
                                  do
                                    echo "<option value=\"$dev\" >$dev</option>"
                                  done
                                %>
                            </select>
                        </div>
                    </label>
                    <label class="">
                        <div class="name">APN设置：</div>
                        <div id="apn">
              <select class="apn" name="apn" onchange="mask_method()">
								<option value="3gnet" <% [ `uci get network.4g.apn |grep "3gnet"` ] && echo 'selected="true"' %> >联通/移动</option>
								<option value="ctnet" <% [ `uci get network.4g.apn |grep "ctnet"` ] && echo 'selected="true"' %> >电信</option>
								<option value=""  >自定义</option>
							</select>
                        </div>
                    </label>
                    <label class="">
                        <div class="name">用户名：</div>
                        <div>
                            <input id="username" name="username" type="text" value="<% uci get network.4g.username %>" placeholder="非必填，可留空" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name">密码：</div>
                        <div>
                            <input id="password" name="password" type="text" value="<% uci get network.4g.password %>"  placeholder="非必填，可留空" />
                        </div>
                    </label>
                    <label class="">
                        <div class="name">PIN码：</div>
                        <div>
                            <input id="pincode" name="pincode" type="text" value="<% uci get network.4g.pincode %>" placeholder="非必填，可留空" />
                        </div>
                    </label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:setlan()">保存</a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>

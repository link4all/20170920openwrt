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
        $("#status").html("正在设置LAN口....请等待网络重启！");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/setlan.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.ipaddr==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("已设置LAN ip为:"+json.ipaddr);
             }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }
        function mask_method(){
        var index=$('.mask option').index($('.mask option:selected'));
        if (index==3){
         $("#mask").html('<input id="mask" name="mask" type="text"  />');
         }
        }
     
  </script>
</head>
<body>
    <div class="current">当前位置：网络设置 > LAN口设置</div> 
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title">LAN口设置 <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">

                    <label class="">
                        <div class="name">IP 地址：</div>
                        <div>
                            <input id="lanip" name="lanip" type="text" value="<% uci get network.lan.ipaddr %>" />
                            
                        </div>
                    </label>
                    <label class="">
                        <div class="name">子网掩码：</div>
                        <div id="mask">
              <select class="mask" name="mask" onchange="mask_method()">
								<option value="255.255.255.0" <% [ `uci get network.lan.netmask |grep "255.255.255.0"` ] && echo 'selected="true"' %> >255.255.255.0</option>
								<option value="255.255.0.0" <% [ `uci get network.lan.netmask |grep "255.255.0.0"` ] && echo 'selected="true"' %> >255.255.0.0</option>
								<option value="255.0.0.0" <% [ `uci get network.lan.netmask |grep "255.0.0.0"` ] && echo 'selected="true"' %> >255.0.0.0</option>
								<option value=""  >自定义</option>
							</select>
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
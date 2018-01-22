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
  function setwan(){
        $("#status").html("正在设置WAN口....请等待网络重启！");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/setwan.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.mode==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("已设置为:"+json.mode+"模式");
             }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }
       function in_method_change() {
			var index = $('.in_method option').index($('.in_method option:selected'));
            index = index + 1;
            $('.in_type').hide();
            $('.in_type_' + index).show();
        }
        
        function mask_method(){
        var index=$('.mask option').index($('.mask option:selected'));
        if (index==3){
         $("#mask").html('<input id="mask" name="mask" type="text"  />');
         }
        }
        
   	  $(window).on('load', function () {
      in_method_change();
      });  
  </script>
</head>
<body>
    <div class="current">当前位置：网络设置 > WAN口设置</div> 
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title">WAN口设置 <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">
                    <label>
                        <div class="name">上网模式：</div>
                        <div>
		           <select class="in_method" name="wan_mode" onchange="in_method_change()">
								<option value="static" <% [ `uci get network.wan.proto |grep static` ] && echo 'selected="true"' %> >静态IP</option>
								<option value="pppoe" <% [ `uci get network.wan.proto |grep pppoe` ] && echo 'selected="true"' %> >PPPOE拨号</option>
								<option value="dhcp" <% [ `uci get network.wan.proto |grep dhcp` ] && echo 'selected="true"' %> >DHCP</option>
								<option value="bridge" <% [ `uci get dhcp.lan.ignore` -eq 1 ] && echo 'selected="true"' %> >网桥</option>
							</select>
                        </div>
                    </label>

                    <label class="in_type in_type_1">
                        <div class="name">IP 地址：</div>
                        <div>
                            <input id="wanip" name="wanip" type="text" value="<% uci get network.wan.ipaddr %>" />
                        </div>
                    </label>
                    <label class="in_type in_type_1">
                        <div class="name">子网掩码：</div>
                        <div id="mask">
               <select class="mask" name="st_mask" onchange="mask_method()">
								<option value="255.255.255.0" <% [ `uci get network.wan.netmask |grep "255.255.255.0"` ] && echo 'selected="true"' %> >255.255.255.0</option>
								<option value="255.255.0.0" <% [ `uci get network.wan.netmask |grep "255.255.0.0"` ] && echo 'selected="true"' %> >255.255.0.0</option>
								<option value="255.0.0.0" <% [ `uci get network.wan.netmask |grep "255.0.0.0"` ] && echo 'selected="true"' %> >255.0.0.0</option>
								<option value=""  >自定义</option>
							</select>
                        </div>
                    </label>
                    <label class="in_type in_type_1">
                        <div class="name">网关：</div>
                        <div>
                            <input id="gateway" name="st_gateway" type="text" value="<% uci get network.wan.gateway %>" placeholder="选填，可不填写" />
                        </div>
                    </label>
                    <label class="in_type in_type_1">
                        <div class="name">DNS服务器1：</div>
                        <div>
                            <input  name="st_dns1" type="text" value="<% uci get network.wan.dns |awk '{print $1}' %>" placeholder="选填，可不填写"/>
                         </div>
                     </label>   
                     <label class="in_type in_type_1">
                         <div class="name">DNS服务器2: </div>
                         <div>
                            <input  name="st_dns2" type="text" value="<% uci get network.wan.dns |awk '{print $2}' %>" placeholder="选填，可不填写" />
                        </div>
                    </label>
                    <label class="in_type in_type_2">
                        <div class="name">用户名：</div>
                        <div>
                            <input id="user" name="user" type="text" value="<% uci get network.wan.username %>" />
                        </div>
                    </label>
                    <label class="in_type in_type_2">
                        <div class="name">密码：</div>
                        <div>
                            <input id="passwd" name="passwd" type="text" value="<% uci get network.wan.password %>" />
                        </div>
                    </label>

			               <label  class="in_type in_type_4">
                        <div class="name">网关：</div>
                        <div>
                            <input id="gw" name="br_gateway" type="text" value="<% uci get network.wan.gateway %>" placeholder="选填，可不填写"/>
                        </div>
                    </label>
                       <label class="in_type in_type_4">
                        <div class="name">DNS服务器1：</div>
                        <div>
                            <input  name="br_dns1" type="text" value="<% uci get network.wan.dns |awk '{print $1}' %>" placeholder="选填，可不填写"/>
                         </div>
                     </label>   
                     <label class="in_type in_type_4">
                         <div class="name">DNS服务器2：</div>
                         <div>
                            <input  name="br_dns2" type="text" value="<% uci get network.wan.dns |awk '{print $2}' %>" placeholder="选填，可不填写"/>
                        </div>
                    </label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:setwan()">保存</a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>
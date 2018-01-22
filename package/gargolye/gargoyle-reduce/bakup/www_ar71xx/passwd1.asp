<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>
    <script type="text/javascript" src="/jjs/jquery.js"></script>
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />
    <script type="text/javascript" src="/jjs/plugin/pintuer/pintuer.js"></script>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/form.css" />

    <script type="text/javascript">
	function setpasswd()
  {
       if(document.getElementById("passwd").value == document.getElementById("repasswd").value)
       {
        $("#status").html("正在设置密码！");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/setpasswd.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("密码已设置为"+json.stat+",请牢记！");
             }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
       }
      else
      {
      $("#status").html("两次密码输入不相同，请重新输入！");
      }
    }    
      
 function setwebaccess()
  {
        $("#status").html("已设置成功，请刷新后查看！");
         var form = new FormData(document.getElementById("form1"));
           $.ajax({
          url: "/cgi-bin/setwebaccess.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("外网访问控制设置已完成！");
             }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    } 
      
    function showpasswd(){
      var pass=document.getElementById("passwd")
      if (pass.type=="password"){
         pass.type="text";
         document.getElementById("repasswd").type="text";
         document.getElementById("dispass").value="隐藏密码";
         }
        else{
         pass.type="password"; 
         document.getElementById("repasswd").type="password";
        document.getElementById("dispass").value="显示密码"
        }
     }
     
    </script>
    <style type="text/css">
    .current{
    height:50px;width:100%;background:#fff;color:#000;border-bottom:solid #e3e9ed 1px;font-size:14px;line-height:50px;text-indent:20px;
     }
    </style>
</head>
<body>
  <div class="current">当前位置：系统维护 > Web访问管理</div> 
    <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title">Web访问管理<p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">

                <div class="tab">
                    <div class="tab-head">
                        <ul id="tabpanel1" class="tab-nav">
                            <li class="active">
                                <a href="#tab-1">Web密码设置</a>
                            </li>
                            <li>
                                <a href="#tab-2">外网访问控制</a>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-body ">
                      <div class="tab-panel active" id="tab-1" style="padding: 15px;">
             <form class="form-info" id="form0">
                
                    <label class="">
                        <div class="name">输入密码：</div>
                        <div>
                            <input id="passwd" name="passwd" type="password"  value="" />         
                        </div>
                    </label>
                    <label class="">
                        <div class="name">确认密码：</div>
                        <div>
                            <input id="repasswd" name="repasswd" type="password" value="" /> 
                            <input id="dispass" class="green-btn" type="button" value="显示密码" onclick="showpasswd()"/>        
                        </div>
                    </label>
            </form>
										  <div class="btn-wrap">
					            <div class="save-btn fr"><a href="javascript:setpasswd()">保存</a></div>
					            </div>

                    </div>
                        <div class="tab-panel" id="tab-2">
                        <form class="form-info" id="form1">
                                <label>
                                    <div class="name">外网访问控制：</div>
                                    <div>
                                        <input id="webctrl" type="checkbox" name="webctrl" value="1"  <% [ `uci get firewall.@zone[1].input|grep "ACCEPT"` ]  && echo "checked" %>/>允许外网访问
                                    </div>
                                </label>
                                <label>
                                    <div class="name">web端口号：</div>
                                    <div>
                                        <input id="webport" name="webport" type="text"  placeholder="80" value=<% uci get uhttpd.main.listen_http |awk -F: '{print $2}' %>/>
                                    </div>
                                </label>
                            </form>    
              <div class="btn-wrap">
              <div class="save-btn fr"><a href="javascript:setwebaccess()">保存</a></div>
              </div>
                        </div>
                    </div>
                </div>
           </div>
        </div>
    </div>
</body>
</html>

<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script type="text/javascript" src="/jjs/jquery.js"></script>
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />
    <script type="text/javascript" src="/jjs/plugin/pintuer/pintuer.js"></script>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/form.css" />

    <script type="text/javascript">
    
     function restoreconfig()
  {
        $("#status").html("正在上传备份文件！");
         var form = new FormData(document.getElementById("form2"));
           $.ajax({
          url: "/cgi-bin/backup.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("已恢复备份文件，正在重启！");
                 }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    } 
       
 function restorefactory()
  {
        $("#status").html("正在恢复出厂设置！");
         var form = new FormData(document.getElementById("form1"));
           $.ajax({
          url: "/cgi-bin/backup.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("已恢复出厂设置，正在重启！");
                 }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    } 
      
    function backup()
  {
        $("#status").html("正在打包备份文件，请稍侯！");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/backup.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("设置出错请重新刷新页面后再设置");
             }else{
                $("#status").html("打包完成，请下载！");
                window.location="/cgi-bin/dump_backup_tarball.sh"
             }
          },  
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    } 
     
    </script>
    <style type="text/css">
    .current{
    height:50px;width:100%;background:#fff;color:#000;border-bottom:solid #e3e9ed 1px;font-size:14px;line-height:50px;text-indent:20px;
     }
    </style>
</head>
<body>
  <div class="current">当前位置：系统维护 > 备份/恢复</div> 
    <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title">备份/恢复<p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">

                <div class="tab">
                    <div class="tab-head">
                        <ul id="tabpanel1" class="tab-nav">
                            <li class="active">
                                <a href="#tab-1">备份配置</a>
                            </li>
                            <li>
                                <a href="#tab-2">恢复出厂设置</a>
                            </li>
                             <li>
                                <a href="#tab-3">恢复备份配置</a>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-body ">
                      <div class="tab-panel active" id="tab-1" >
                        <form class="form-info" id="form0">
                        <input name="backup" type=hidden value="1" />
                         </form>
										    <div class="btn-wrap">
					               <div class="save-btn fr"><a href="javascript:backup()">备份配置</a></div>
					               </div>
                      </div>
                        <div class="tab-panel" id="tab-2">
                         <form class="form-info" id="form1">
                        <input name="restorefactory" type=hidden value="1" />
                         </form>
                          <div class="btn-wrap">
                          <div class="save-btn fr"><a href="javascript:restorefactory()">恢复出厂设置</a></div>
                          </div>
                        </div>
                        <div class="tab-panel" id="tab-3">
                          <form class="form-info" id="form2">
                        <label class="">
                       
                        <div>
                            <input id="backfiles" name="backfiles" type="file"  /> 上传备份文件
                           
                        </div>
                    </label>
                    </form>
                          <div class="btn-wrap">
                          <div class="save-btn fr"><a href="javascript:restoreconfig()">恢复备份配置</a></div>
                          </div>
                        </div>
                    </div>
                </div>
           </div>
        </div>
    </div>
</body>
</html>

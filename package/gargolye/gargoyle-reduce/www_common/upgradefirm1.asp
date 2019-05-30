<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: text/html"
echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/upgradefirm.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>

    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/form.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <script type="text/javascript" src="/jjs/jquery.js"></script>
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />
    <script type="text/javascript" src="/jjs/plugin/pintuer/pintuer.js"></script>


  <script type="text/javascript">
  function upload(){
        $("#status").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/upgradefirm.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status").html("<%= $error%>");
             }else if (json.stat=="ok"){
                $("#status").html("<%= $wait%>");
                setTimeout("upgradefirm()", 2000 )
             }
             else{
                $("#status").html("<%= $illegal%>");
             }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }

  function upgradefirm(){
        $("#status").html("<%= $processing2%><img src='/images/loading.gif' />");
        $.ajax({
          timeout:0,
          url: "/cgi-bin/upgradefirm.sh",
          type: "POST",
          data: {"upgrade": "yes"},
          contentType: "application/json; charset=utf-8",
          success: function(json) {
          if (json.stat=="not"){
             $("#status").html("<%= $nofile%>");
          }
          if (json.stat=="ok"){
             $("#status").html("<%= $upgrade_ok %>");
          }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }

  function write_firm(){
        $.ajax({
          timeout:0,
          url: "/cgi-bin/ota.sh",
          type: "POST",
          data: {"action": "ota_upgrade"},
          contentType: "application/json; charset=utf-8",
          success: function(json) {
          if (json.stat=="not"){
             $("#status").html("<%= $nofile%>");
          }
          if (json.stat=="ok"){
             $("#status").html("<%= $upgrade_ok %>");
          }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }

        function otaupgrade(){
        $("#status").html("<%= $download_firm %><img src='/images/loading.gif' />");
        $.ajax({
          timeout:0,
          url: "/cgi-bin/ota.sh",
          type: "POST",
          data: {"action": "getfirm"},
          contentType: "application/json; charset=utf-8",
          success: function(json) {
          if (json.stat=="not"){
             $("#status").html("<%= $md5_nomatch %>");
          }
          if (json.stat=="ok"){
             $("#status").html("<%= $processing2 %>");
             write_firm()
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
         td{
        text-align:center;/** 设置水平方向居中 */
        vertical-align:middle/** 设置垂直方向居中 */
       }
        </style>
</head>
<body>
                <div class="current"><%= $location%></div>
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
                <div class="title"><%= $page%> <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
              <div class="tab">
                    <div class="tab-head">
                        <ul id="tabpanel1" class="tab-nav">
                            <li class="active">
                                <a href="#tab-1"><%= $loc_upgrade%></a>
                            </li>
                            <li>
                                <a href="#tab-2"><%= $rem_upgrade%></a>
                            </li>
                        </ul>
                    </div>
                <div class="tab-body ">
                    <div class="tab-panel active" id="tab-1" >
                            <form class="form-info" id="form0">
                                <label class="">
                                    <div class="name"><%= $up_firm%></div>
                                    <div>
                                        <input id="firmware" name="firmware" type="file" value=""  />
                                    </div>
                                </label>
                            </form>
                            <div class="btn-wrap">
                              <div class="save-btn fr"><a href="javascript:upload()"><%= $loc_upgrade%></a></div>
                            </div>
                    </div>  
                    <div class="tab-panel" id="tab-2">
                      <div class="wrap-table">
                        <table border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td><%= $cur_firm%></td>
                            <td><% cat /etc/openwrt_release |grep BULDTIME|cut -d"'" -f2|cut -d" " -f1 %> </td>
                          </tr>
                          <tr>
                              <td><%= $last_firm %></td>
                              <% 
                                  if ping downloads.iyunlink.com -c1 > /dev/null 2>&1;then
                                      curl http://downloads.iyunlink.com/firmware/$(cat /tmp/sysinfo/board_name)/version.txt -o /tmp/version.txt  > /dev/null 2>&1
                                      soft_ver=$(cat /tmp/version.txt |grep VER|cut -d"=" -f2)
                                      else
                                      soft_ver="unknow"
                                  fi
                                      %>
                              <td id='soft_ver'><%= $soft_ver%></td>
                            </tr>
                        </table>
                        
                       </div>
                          <div class="btn-wrap">
                              <div class="save-btn fr"><a href="javascript:otaupgrade()"><%= $rem_upgrade%></a></div>
                            </div>
                    </div>
                 </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>


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
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript" src="jjs/jquery.js"></script>
<link rel="stylesheet" type="text/css" href="css/form.css" />
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


  </script>
</head>
<body>
    <div class="current"><%= $location%></div>
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $page%> <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">
                   <label class="">
                        <div class="name"><%= $up_firm%></div>
                        <div>
                            <input id="firmware" name="firmware" type="file" value=""  />
                        </div>
                    </label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:upload()"><%= $save%></a><a href="javascript:upgradefirm()"><%= $upgrade%></a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>


<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/backup.po
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
        $("#status").html("<%= $on_upload%>");
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
             $("#status").html("<%= $error%>");
             }else{
                $("#status").html("<%= $finish_back%>");
                 }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    }

 function restorefactory()
  {
        $("#status").html("<%= $processing%>");
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
             $("#status").html("<%= error%>");
             }else{
                $("#status").html("<%= $finish_restore%>");
                 }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    }

    function backup()
  {
        $("#status").html("<%= $on_back%>");
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
             $("#status").html("<%= $error%>");
             }else{
                $("#status").html("<%= $download%>");
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
  <div class="current"><%= $location%></div>
    <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $page%><p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">

                <div class="tab">
                    <div class="tab-head">
                        <ul id="tabpanel1" class="tab-nav">
                            <li class="active">
                                <a href="#tab-1"><%= $bk_config%></a>
                            </li>
                            <li>
                                <a href="#tab-2"><%= $restore%></a>
                            </li>
                             <li>
                                <a href="#tab-3"><%= $restore_bk%></a>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-body ">
                      <div class="tab-panel active" id="tab-1" >
                        <form class="form-info" id="form0">
                        <input name="backup" type=hidden value="1" />
                         </form>
										    <div class="btn-wrap">
					               <div class="save-btn fr"><a href="javascript:backup()"><%= $bk_config%></a></div>
					               </div>
                      </div>
                        <div class="tab-panel" id="tab-2">
                         <form class="form-info" id="form1">
                        <input name="restorefactory" type=hidden value="1" />
                         </form>
                          <div class="btn-wrap">
                          <div class="save-btn fr"><a href="javascript:restorefactory()"><%= $restore%></a></div>
                          </div>
                        </div>
                        <div class="tab-panel" id="tab-3">
                          <form class="form-info" id="form2">
                        <label class="">

                        <div>
                            <input id="backfiles" name="backfiles" type="file"  /> <%= $up_bakfiles%>

                        </div>
                    </label>
                    </form>
                          <div class="btn-wrap">
                          <div class="save-btn fr"><a href="javascript:restoreconfig()"><%= $restore_bk%></a></div>
                          </div>
                        </div>
                    </div>
                </div>
           </div>
        </div>
    </div>
</body>
</html>

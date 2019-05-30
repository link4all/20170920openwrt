<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Set Mac</title>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript" src="jjs/jquery.js"></script>
<link rel="stylesheet" type="text/css" href="css/form.css" />
  <script type="text/javascript">
    function modifyserver(){
      $("#macserver").removeAttr("disabled");  

    }


  function setmac(){ 
    var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/setmac.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.status=="ok"){
             $("#status").html("mac: "+json.mac+",write "+json.status + "!");
             $("#mac").val(json.mac);
             }else{
                $("#status").html(json.status);
             }
          },
          error: function(error) {
               $("#status").html("Set mac error");
          }
        });

  }
  </script>
</head>
<body>

        <div class="wrap">
            <div class="title">Set mac<p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">
                <label class="">
                    <div class="name">Current mac ：</div>
                    <div>
                      <%       
                      . /lib/functions.sh
                      . /lib/functions/system.sh
                      mac=`mtd_get_mac_binary art 4098  |tr "[a-z]" "[A-Z]"`
                      %>
                        <input id="mac" name="mac" type="text" value="<%= $mac %>" disabled="disabled"/>
                    </div>
                </label>
                    <label class="">
                        <div class="name">Server IP ：</div>
                        <div>
                            <input id="macserver" name="macserver" type="text" value="<% uci get 4g.server.macserver %>" disabled="disabled"/>
                        </div>
                    </label>
            </form>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:setmac()">SetMAC</a></div>
          </div>
          <div class="btn-wrap">
            <div class="save-btn fr"><a href="javascript:modifyserver()">Modify Server</a></div>
            </div>
         </div>
</body>
</html>

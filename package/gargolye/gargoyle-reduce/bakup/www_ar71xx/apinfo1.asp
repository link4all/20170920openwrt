<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo ""
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>
    <link rel="stylesheet" type="text/css" href="/jjs/plugin/iPath1/iPath.css" />
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript" src="jjs/jquery.js"></script>
  <script type="text/javascript">
   function getwificlientlist(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/getwificlient.sh",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
                  for (var key in json) {
               var tbody="";
              tbody += '<tr><td>'+ key + '</td><td>' + json[key].signal + '</td><td>' +json[key].rxbytes + '</td><td>' + json[key].txbytes + '</td></tr>';
              $("#apclient").append(tbody);
               }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
      function getarplist(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/getarp.sh",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
                  for (var key in json) {
        var tbody="";
              tbody += '<tr><td>'+ key + '</td><td>' + json[key].mac + '</td><td>' +json[key].flag + '</td></tr>';
              $("#arplist").append(tbody);
               }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
	  $(window).on('load', function () {
      getwificlientlist()
      getarplist()
      });
    </script>
</head>
<body>
    <div class="current">当前位置：系统状态 > 客户端信息</div>
    <div class="wrap-main" style="position: relative;min-height: 100%">
        <div class="wrap">
            <div class="title">无线主机</div>
            <div class="wrap-table">
                <table border="0" cellspacing="0" cellpadding="0" class="table-con">
                    <thead>
                        <th>MAC 地址</th>
                         <th>信号强度（dbm）</th>
                          <th>RX（Bytes）</th>
                          <th>TX (Btyes)</th>
                    </thead>
                    <tbody id="apclient">

                    </tbody>
                </table>
            </div>
        </div>

        <div class="wrap">
            <div class="title">ARP列表</div>
            <div class="wrap-table">
                <table border="0" cellspacing="0" cellpadding="0" class="table-con">
                    <thead>
                        <th>IP地址</th>
                        <th>MAC 地址</th>
                        <th>标记<br />(0x0不在线，0x2在线)</th>

                    </thead>
                    <tbody id="arplist">

                    </tbody>
                </table>
            </div>
        </div>

</body>
</html>

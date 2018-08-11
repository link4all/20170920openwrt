<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/statics.po
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
        function getstatics(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/getstatics.sh",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
                  for (var key in json) {
        var tbody="";
              var total= (json[key].txbytes + json[key].rxbytes)/1024/1024
                total=total.toFixed(2)
              tbody += '<tr><td>'+ key
                 + '</td><td>' + json[key].rxbytes
                 + '</td><td>' +json[key].rxerror
                 + '</td><td>' +json[key].rxdrop
                 + '</td><td>' + json[key].txbytes
                 + '</td><td>' +json[key].txerror
                 + '</td><td>' +json[key].txdrop
                 + '</td><td>' + total + '</td></tr>';
              $("#statics").append(tbody);
               }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
	  $(window).on('load', function () {
      getstatics()
      });
    </script>
</head>
<body>
    <div class="current"><%= $location%></div>
    <div class="wrap-main" style="position: relative;min-height: 100%">
        <div class="wrap">
            <div class="title"><%= $page%></div>
            <div class="wrap-table">
                <table border="0" cellspacing="0" cellpadding="0" class="table-con">
                    <thead>
                        <th><%= $ifname%></th>
                        <th><%= $rx%>（RX Bytes）</th>
                        <th><%= $rx_error%>（packets）</th>
                        <th><%= $rx_lost%>（packets）</th>
                        <th><%= $tx%> (TX Bytes) </th>
                        <th><%= $tx_error%>（packets）</th>
                        <th><%= $tx_lost%>（packets）</th>
                        <th><%= $total%> (MBtye)</th>
                    </thead>
                    <tbody id="statics">

                    </tbody>
                </table>
            </div>
        </div>

</body>
</html>

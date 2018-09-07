<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/wifisetting.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Sytem Log</title>
    <style>
            #syslog {  width: 100%; }
    </style>  
</head>
<body>
    <h2> <a id="content" name="content">System Log</a></h2>    
    <div id="content_syslog">   
    <textarea readonly="readonly" wrap="off" rows=<% dmesg|grep -E '\n' -c %> id="syslog"  >
<% dmesg %>    
    </textarea>
    </div>


</body>
</html>


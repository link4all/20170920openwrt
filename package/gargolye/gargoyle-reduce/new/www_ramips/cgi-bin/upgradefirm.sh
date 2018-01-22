#!/usr/bin/haserl --upload-limit=16348 --upload-dir=/tmp/
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ -n "$FORM_firmware"  ];then
mv $FORM_firmware /tmp/firmware.bin >/dev/null 2>&1
sysupgrade -T /tmp/firmware.bin >/dev/null 2>&1
  if [ `echo $?` -ne 0 ];then
    echo "{"
    echo "\"stat\":\"not\""
    echo "}"
    else
    echo "{"
    echo "\"stat\":\"ok\""
    echo "}"
  sysupgrade -n  /tmp/firmware.bin  >/dev/null 2>&1
  fi
fi

%>


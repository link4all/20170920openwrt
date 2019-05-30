#!/usr/bin/haserl --upload-limit=16348 --upload-dir=/tmp/
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""


upgrade_firm(){
      fw_setenv have_fw 0 > /dev/null 2>&1 
    .  /lib/upgrade/common.sh
    run_ramfs 'cd /tmp/;mtd erase /dev/mtd8;mtd write /tmp/firmware.bin /dev/mtd8; sleep 5;reboot '
}
if [ "$FORM_action" = "getfirm" ];then
    board=$(cat /tmp/sysinfo/board_name)
    ver=$(cat /tmp/version.txt |grep VER|cut -d"=" -f2)
    md5_val=$(cat /tmp/version.txt |grep MD5SUM|cut -d"=" -f2)
    curl http://downloads.iyunlink.com/firmware/${board}/${ver}/${board}_${ver}.bin -o /tmp/firmware.bin  > /dev/null 2>&1
    if [ "$md5_val" = "$(md5sum /tmp/firmware.bin|awk '{print $1}')" ];then
        echo "{"
        echo "\"stat\":\"ok\""
        echo "}"
        else
        echo "{"
        echo "\"stat\":\"not\""
        echo "}"
    fi
fi

if [ "$FORM_action" = "ota_upgrade" ];then
  if [ $(ls /tmp/firmware.bin  -l |awk '{print $5}') -gt 5000000  ];then
   upgrade_firm 
        echo "{"
        echo "\"stat\":\"ok\""
        echo "}"
        else
        echo "{"
        echo "\"stat\":\"not\""
        echo "}"
  fi
fi





%>

#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [  "$FORM_type" = "get" ];then
  reboottype=`uci get system.@system[0].reboottype`
  echo "{"
  echo "\"reboottype\":\"$reboottype\""
  echo "}"
fi


if [ -n "$FORM_boot" ];then
  echo "{"
  echo "\"rebootnow\":\"ok\""
  echo "}"
  reboot >/dev/null 2>&1
fi


if [ "$FORM_type" = "none" ];then
  echo "{"
echo "\"type\":\"$FORM_type\","
echo "\"time\":\"$FORM_time\""
echo "}"
  uci set system.@system[0].reboottype="$FORM_type"
  uci del system.@system[0].week
  uci del system.@system[0].time
  uci commit system
  sed -i '/reboot/d' /etc/crontabs/root
    killall crond
  /usr/sbin/crond  -f -c /etc/crontabs &  >/dev/null 2>&1
 # /etc/init.d/cron restart >/dev/null 2>&1
fi

if [ "$FORM_type" = "day" ];then
echo "{"
echo "\"type\":\"$FORM_type\","
echo "\"time\":\"$FORM_time\""
echo "}"
  uci set system.@system[0].reboottype="$FORM_type"
  uci del system.@system[0].week
  uci set system.@system[0].time="$FORM_time"
  uci commit system
  hour=`echo $FORM_time |awk -F: '{print $1}'`
  minute=`echo $FORM_time |awk -F: '{print $2}'`
  sed -i '/reboot/d' /etc/crontabs/root
  echo "$minute $hour * * * /sbin/reboot" >> /etc/crontabs/root
  killall crond
  /usr/sbin/crond  -f -c /etc/crontabs &  >/dev/null 2>&1
 #/etc/init.d/cron restart & >/dev/null 2>&1
fi

if [ "$FORM_type" = "week" ];then
  echo "{"
echo "\"type\":\"$FORM_type\","
echo "\"week\":\"$FORM_week\","
echo "\"time\":\"$FORM_time\""
echo "}"
  uci set system.@system[0].reboottype="$FORM_type"
  uci set system.@system[0].week="$FORM_week"
  uci set system.@system[0].time="$FORM_time"
  uci commit system
  hour=`echo $FORM_time |awk -F: '{print $1}'`
  minute=`echo $FORM_time |awk -F: '{print $2}'`
  week=`echo $FORM_week | sed  's/[ ]/,/g'`
  sed -i '/reboot/d' /etc/crontabs/root
  echo "$minute $hour * * $week /sbin/reboot" >> /etc/crontabs/root
    killall crond
  /usr/sbin/crond  -f -c /etc/crontabs &  >/dev/null 2>&1
  #/etc/init.d/cron restart >/dev/null 2>&1
fi



%>

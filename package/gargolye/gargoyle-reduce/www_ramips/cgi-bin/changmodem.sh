#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_vendor" = "yy" ];then
   rm /etc/modules.d/AutoProbe-usb-net-gobinet*
   echo "gobinet_yy.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
echo "{"
echo "\"stat\":\"Gobinet driver is for Quectel Now,Please reboot!\""
echo "}"
fi

if [ "$FORM_vendor" = "xy" ];then
   rm /etc/modules.d/AutoProbe-usb-net-gobinet*
   echo "gobinet_xy.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
echo "{"
echo "\"stat\":\"Gobinet driver is for XinYi Now, Please reboot!\""
echo "}"
fi

if [ "$FORM_vendor" = "fg" ];then
   rm /etc/modules.d/AutoProbe-usb-net-gobinet*
   echo "gobinet_fg.ko" > /etc/modules.d/AutoProbe-usb-net-gobinet
echo "{"
echo "\"stat\":\"Gobinet driver is for MeiGe Now,Please reboot!\""
echo "}"
fi

%>


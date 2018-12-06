#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""
   sim=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/getsimstatus.gcom 2>/dev/null`
   sig=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/getstrength.gcom  |grep  "," |cut -d: -f2|cut -d, -f1 2>/dev/null`
   if uci -q get 4g.modem.imei |grep  "^[[:digit:]]*$" 2>&1 >/dev/null ;then
   imei=`uci -q get 4g.modem.imei`
   else
   imei=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/getimei.gcom 2>/dev/null`
   uci -q set 4g.modem.imei=$imei
   fi
   if uci -q get 4g.modem.imsi |grep  "^[[:digit:]]*$" 2>&1 >/dev/null;then
   imsi=`uci -q get 4g.modem.imsi`
   else
   imsi=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/getimsi.gcom 2>/dev/null`
   uci -q set 4g.modem.imsi=$imsi
   fi
   if uci -q get 4g.modem.iccid |grep  "^[[:digit:]]*$" 2>&1 >/dev/null;then
   iccid=`uci -q get 4g.modem.iccid`
   else
   iccid=`gcom -d $(uci get 4g.modem.device) -s /etc/gcom/iccid_forge.gcom 2>/dev/null |awk '{print $2}' 2>/dev/null`
   uci -q set 4g.modem.iccid=$iccid
   fi
   uci commit 4g
 echo "{"
  echo "\"sim\":\"$sim\","
  echo "\"sig\":\"$sig\","
  echo "\"imei\":\"$imei\","
  echo "\"imsi\":\"$imsi\","
  echo "\"iccid\":\"$iccid\""


echo "}"
%>

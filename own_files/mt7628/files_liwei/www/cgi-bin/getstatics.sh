#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""
echo "{"
i=0
#cat /proc/net/dev |grep -v "lo"|grep -v "gre0" |grep -v "tap0" |grep -v "teql0"|grep -v "imq"|grep -Ev "ra[1-3]"|grep -Ev "ifb[0-1]"|grep -v "mon0" |grep -v "ra3"|grep -v "apcli" |grep -v "drop"  |grep -v "Receive" | while read line
if cat /proc/net/dev |grep eth1 2>&1 >/dev/null;then
iface="eth0.1 eth0.2 ra0 eth1"
else
iface="eth0.1 eth0.2 ra0 "
fi
for k in $iface
do
  if [ $i -ne 0 ];then
 	echo ","
	fi
  line=`cat /proc/net/dev |grep $k`
  if [ $k = "eth0.1" ];then
  interface="Lan"
  fi
  if [ $k = "eth0.2" ];then
  interface="Wan"
  fi
  if [ $k = "ra0" ];then
  interface="WiFi"
  fi
  if [ $k = "eth1" ];then
  interface="4G"
  fi

  rxbytes=`echo $line |awk '{print $2}'`
  rxerror=`echo $line |awk '{print $4}'`
  rxdrop=`echo $line |awk '{print $5}'`
  txbytes=`echo $line |awk '{print $10}'`
  txerror=`echo $line |awk '{print $12}'`
  txdrop=`echo $line |awk '{print $13}'`
    
 	
  let i+=1
  
  echo "\"$interface\":{"
  echo "\"rxbytes\":$rxbytes,"
  echo "\"rxerror\":$rxerror,"
  echo "\"rxdrop\":$rxdrop,"
  echo "\"txbytes\":$txbytes,"
  echo "\"txerror\":$txerror,"
  echo "\"txdrop\":$txdrop"
  echo -n "}"
done
echo "}"
%>

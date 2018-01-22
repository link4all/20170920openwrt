#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""
echo "{"
i=0
cat /proc/net/dev |grep -v "lo"|grep -v "gre0" |grep -v "tap0" |grep -v "teql0"|grep -v "imq" |grep -v "apcli" |grep -v "drop" |grep -v "Receive" | while read line
do
  interface=`echo $line |awk '{print $1}'`
  rxbytes=`echo $line |awk '{print $2}'`
  rxerror=`echo $line |awk '{print $4}'`
  rxdrop=`echo $line |awk '{print $5}'`
  txbytes=`echo $line |awk '{print $10}'`
  txerror=`echo $line |awk '{print $12}'`
  txdrop=`echo $line |awk '{print $13}'`
    
  if [ $i -ne 0 ];then
 	echo ","
	fi
	
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

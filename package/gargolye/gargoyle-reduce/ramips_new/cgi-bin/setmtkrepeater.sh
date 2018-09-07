#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

encx=psk
if [ $FORM_setrepeater = 1 ];then
	if [ "$FORM_etype"x = "WPA1PSKWPA2PSK/TKIPAES"x ]; then
			      umode="WPA2PSK"
        		uencryp="AES"
		elif [ "$FORM_etype"x = "WPA1PSKWPA2PSK/AES"x ]; then
			      umode="WPA2PSK"
        		uencryp="AES"
		elif [ "$FORM_etype"x = "WPA2PSK/AES"x ]; then
        		umode="WPA2PSK"
        		uencryp="AES"
  	  	elif [ "$FORM_etype"x = "WPA2PSK/TKIP"x ]; then
        		umode="WPA2PSK"
	        	uencryp="TKIP"
   		elif [ "$FORM_etype"x = "WPAPSK/TKIPAES"x ]; then
        		umode="WPAPSK"
	        	uencryp="TKIP"
		elif [ "$FORM_etype"x = "WPAPSK/AES"x ]; then
   			umode="WPAPSK"
        	uencryp="AES"
		elif [ "$FORM_etype"x = "WPAPSK/TKIP"x ]; then
    		umode="WPAPSK"
        	uencryp="TKIP"
		elif [ "$FORM_etype"x = "WEP"x ]; then
    		umode="WEP"
        	uencryp="WEP"
			encx=wep
   		fi


uci set wireless.sta.ssid="$FORM_essid"
uci set wireless.sta.key="$FORM_epwd"
uci set wireless.ra0.channel="$FORM_channel"
uci set wireless.ra0.encryption=$encx
uci set wireless.sta.disabled='0'
else
uci set wireless.sta.disabled='1'
uci set wireless.sta.key="any"
fi



echo "{"
echo "\"success\":\"ok\",\"enc\":\"$FORM_etype $FORM_essid $FORM_channel\""
echo "}"
uci commit wireless
/etc/init.d/network restart
%>

#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

maclist=`echo "$FORM_maclist" |tr -d "\r" |sed 's/|/ /g'`
uci delete firewall.macfilter.maclist
echo -en "" >/etc/firewall.user

uci set firewall.macfilter=macfilter
if [ -n "$maclist" ];then
for i in $maclist
do
uci add_list firewall.macfilter.maclist=$i
echo "iptables -I FORWARD  -m mac --mac-source $i -j DROP" >> /etc/firewall.user
done
fi



echo "{"
echo "\"status\":\"$maclist\""
echo "}"

uci commit firewall
/etc/init.d/firewall restart

%>

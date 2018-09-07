#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

while  uci -q delete firewall.@redirect[-1]
do
uci -q delete firewall.@redirect[-1]
done


for i in `seq 1 $FORM_num`
do
sport=`eval echo '$'FORM_sport_"$i"`
dip=`eval echo '$'FORM_dip_"$i"`
dport=`eval echo '$'FORM_dport_"$i"`
proto=`eval echo '$'FORM_proto_"$i"`
echo "$target $mask $gw $metric" >> /tmp/kkk
uci add firewall redirect 2>&1 >/dev/null
uci set firewall.@redirect[$(($i-1))].target='DNAT'
uci set firewall.@redirect[$(($i-1))].src='wan'
uci set firewall.@redirect[$(($i-1))].name=$i

uci set firewall.@redirect[$(($i-1))].src_dport=$sport
uci set firewall.@redirect[$(($i-1))].dest_ip=$dip
uci set firewall.@redirect[$(($i-1))].dest_port=$dport
uci set firewall.@redirect[$(($i-1))].proto="$proto"
done
uci commit firewall


echo "{"
echo "\"status\":\"$FORM_num\""
echo "}"

%>

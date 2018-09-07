#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

while  uci -q delete network.@route[-1]
do
uci -q delete network.@route[-1]
done


for i in `seq 1 $FORM_num`
do
target=`eval echo '$'FORM_target_"$i"`
mask=`eval echo '$'FORM_mask_"$i"`
gw=`eval echo '$'FORM_gw_"$i"`
metric=`eval echo '$'FORM_metric_"$i"`
uci add network route 2>&1 >/dev/null
uci set network.@route[$(($i-1))].interface='lan'
uci set network.@route[$(($i-1))].target=$target
uci set network.@route[$(($i-1))].netmask=$mask
uci set network.@route[$(($i-1))].gateway=$gw
uci set network.@route[$(($i-1))].metric=$metric
done
uci commit network


echo "{"
echo "\"status\":\"$FORM_num\""
echo "}"

%>

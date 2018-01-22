#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

echo "" > /tmp/wificlients
for interface in `iw dev | grep Interface | cut -f 2 -s -d" "`
 do
   iw dev $interface  station dump >>  /tmp/wificlients
 done
echo "{"
 awk '
{
if ($1 ~ /^Station/) {
mac=$2;
k++;
if(k>1) print ","
printf("\"%s\":{",mac);
next;
}  else if ($0 ~ /rx bytes:/) {
rx=$NF;
printf("\"rxbytes\":%s,",rx);
next;
} else if ($0 ~ "tx bytes:") {
tx=$NF;
printf("\"txbytes\":%s,",tx);
next;
} else if ($0 ~ /signal:/) {
sig=$2;
printf("\"signal\":%s}",sig);
next;
}
}
' /tmp/wificlients
echo "}"
%>


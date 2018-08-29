#!/usr/bin/haserl
content-type: text/html


 <% 
      uci set wireless.ap.ApCliSsid="$FORM_ssid" ;
      uci set wireless.ap.ApCliWPAPSK="$FORM_passwd";
      uci set wireless.mt7628.channel="$FORM_channel";
      uci commit;
      
      echo "$FORM_ssid,$FORM_passwd,$FORM_channel <br />";
      echo  "restarting network....";
      /etc/init.d/network restart;
 %>
<script>
setTimeout(function() {
    history.go(-1);
}, 2000);
</script>

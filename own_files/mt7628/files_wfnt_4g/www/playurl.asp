#!/usr/bin/haserl
content-type: text/html



 <% 
  #killall gst-launch-1.0;
  #gst-launch-1.0 -t playbin uri="$FORM_url"& >/dev/null
killall madplay;
  wget -O- "$FORM_url" |madplay - & >/dev/null
  
 %>
 <script>
setTimeout(function() {
    history.go(-1);
}, 2000);
</script>

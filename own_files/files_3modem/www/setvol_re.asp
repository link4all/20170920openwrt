#!/usr/bin/haserl
content-type: text/html


<%
  /home/setvol $FORM_vol >/dev/null;
  echo "now volume is $FORM_vol";

%>
<script>
setTimeout(function() {
    history.go(-1);
}, 2000);
</script>

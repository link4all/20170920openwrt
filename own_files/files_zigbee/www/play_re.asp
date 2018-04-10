#!/usr/bin/haserl
content-type: text/html


<%
  echo "now is playing $FORM_radioid ";
  #killall gst-launch-1.0;
  #gst-launch-1.0 -t playbin uri=http://lhttp.qingting.fm/live/$FORM_radioid/64k.mp3&
  killall madplay;
  wget -O- http://lhttp.qingting.fm/live/"$FORM_radioid"/64k.mp3 |madplay - & >/dev/null
    current=$(cat /www/current);
    total=$(wc -l /www/radio.txt |cut -d" " -f1);
    kk=$((${current}+1));
  case $FORM_play in
  next)
    if [[ ${kk} -gt ${total} ]];then
    echo "kkkkkkkkk <br />"
    echo -e "1\c" > /www/current;
    else
    echo  -e "${kk}\c" > /www/current;
    fi
    ;;
    pre)
    if [[ ${kk} -le 2 ]];then
    echo "kkkkkkkkk <br />"
    echo  "1" > /www/current;
    else
    echo  "$((${current}-1))" > /www/current;
    fi
    ;;
    stop)
    #killall gst-launch-1.0
    killall madplay
    ;; 
   esac
    
  
%>
<script>
setTimeout(function() {
    history.go(-1);
}, 2000);
</script>

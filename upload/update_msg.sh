ifconfig |awk '{print $1 $2 $5 $6}' |grep -A 8 wwan0 |grep RXbytes > /root/upload

/root/put_msg > /root/log


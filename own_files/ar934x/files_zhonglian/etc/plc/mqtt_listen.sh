#/bin/sh

deviceId=$(uci get 4g.server.sn)
while true
 do
 mosquitto_sub -h www.yinuo-link-cloud.com  -u admin -P Yinuolink2018 -t $deviceId -C 1 > /tmp/mqttmsg
    
 if [ `jsonfilter -i /tmp/mqttmsg -e @.cmd` == 'upgrade' ];then
    wget http://47.107.143.7:80/sys/Export/DownloadBin?fileName=fireware.bin -O /tmp/firmware.bin
    md5in=`jsonfilter -i /tmp/mqttmsg -e @.MD5`
    md5get=`md5sum /tmp/firmware.bin|awk '{print $1}'`
      if [ "$md5in" == "$md5get"  ];then
          . /lib/functions.sh
        firm_index=`find_mtd_index firmware`
        mtd write /tmp/firmware.bin /dev/mtd${firm_index}
        mosquitto_pub -h www.yinuo-link-cloud.com  -u admin -P Yinuolink2018 -t ZL -m "{\"cmd\":\"upgradeAck\",\"deviceId\":\"$deviceId\",\"upgradeUrl\":\"ok\"}"
          reboot
      fi
  break
 fi

if [ `jsonfilter -i /tmp/mqttmsg -e @.cmd` == 'getGwInfo' ];then
    for i in `ps |grep update |grep -v grep |awk '{print $1}'`
      do
      kill -9 $i
    done
    /etc/plc/updateinfo.sh &

fi

if [ `jsonfilter -i /tmp/mqttmsg -e @.cmd` == 'connectedGw' ];then

cat /sys/class/leds/tp-link\:green\:system/trigger
(echo 0 > /sys/class/leds/tp-link\:green\:system/brightness;sleep 1;echo 255 > /sys/class/leds/tp-link\:green\:system/brightness) &
mosquitto_pub -h www.yinuo-link-cloud.com  -u admin -P Yinuolink2018 -t ZL -m "{\"cmd\":\"connetctAck\",\"deviceId\":\"$deviceId\"}"

fi

 done
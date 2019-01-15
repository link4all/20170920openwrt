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
 done
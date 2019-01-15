#/bin/sh


anotherName=
jingDu=
weiDu=
mapDes=
ownerName=
ownerTel=


once_mqtt(){
 deviceId=$(uci get 4g.server.sn)
 model=$(uci get gargoyle.global.model_name)
 telNumber=$(gcom -d /dev/ttyUSB3 -s /etc/gcom/getimsi.gcom)
 uci -q set 4g.modem.imsi=$telNumber
 hardwareversion=V1.1
 softwareversion=$(uci -q get gargoyle.global.soft_ver)
 ipAddr=$(uci -q get network.lan.ipaddr)
 fourgOperator=$(gcom -d /dev/ttyUSB3 -s /etc/gcom/getregisterednetwork.gcom|cut -d: -f2|cut -d, -f1 |sed $'s/\"//g')
 uci -q set 4g.modem.reg_net="$fourgOperator"
 leavingFactoryNumber=YNAR41-20181218
 
 mosquitto_pub -h www.yinuo-link-cloud.com  -u admin -P Yinuolink2018 -t ZL -m "{\"cmd\":\"auto\",\"deviceId\":\"$deviceId\",\"model\":\"$model\",\"telNumber\":\"$telNumber\",\"hardwareversion\":\"$hardwareversion\",\"softwareversion\":\"$softwareversion\",\"ipAddr\":\"$ipAddr\",\"fourgOperator\":\"$fourgOperator\",\"leavingFactoryNumber\":\"$leavingFactoryNumber\"}"
}

 while true
 do
 if ping 114.114.114.114 -c 2 -W3 >/dev/null 2>&1 ;then
 once_mqtt
 break
 fi
 echo "Wait for network!"
 sleep 1
 done


loop_mtqq(){
   deviceId=$(uci get 4g.server.sn)
signalIntensity=$(gcom -d /dev/ttyUSB3 -s /etc/gcom/getstrength.gcom  |grep "CSQ:" |cut -d" " -f2|cut -d"," -f1)
uci -q set 4g.modem.rssi=${signalIntensity}
clientNumber=`cat /proc/net/arp |grep 0x2 -c`
sim_tx=$(cat /proc/net/dev |grep eth2 |awk '{print $2}')
sim_rx=$(cat /proc/net/dev |grep eth2 |awk '{print $10}')
simDataTotal=$(($sim_tx + $sim_rx))
simDataTotal=$(($simDataTotal/1048576))  
 
wifi_tx=$(cat /proc/net/dev |grep wlan0 |awk '{print $2}')
wifi_rx=$(cat /proc/net/dev |grep wlan0 |awk '{print $10}')
wifiDataTotal=$(($wifi_tx + $wifi_rx))
wifiDataTotal=$(($wifiDataTotal/1048576))
ssid=$(uci get wireless.@wifi-iface[0].ssid)
password=$(uci get wireless.@wifi-iface[0].encryption)
channel=$(uci get wireless.@wifi-device[0].channel)

mosquitto_pub -h www.yinuo-link-cloud.com  -u admin -P Yinuolink2018 -t ZL -m "{\"cmd\":\"auto\",\"deviceId\":\"$deviceId\",\"ssid\":\"$ssid\",\"signalIntensity\":\"`uci -q get 4g.modem.rssi`\",\"clientNumber\":\"$clientNumber\",\"simDataTotal\":\"$simDataTotal\",\"wifiDataTotal\":\"$wifiDataTotal\",\"password\":\"$password\",\"channel\":\"$channel\"}"

}

while true
do
  loop_mtqq
  sleep 200
done
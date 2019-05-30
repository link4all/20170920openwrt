#!/bin/sh
jindu=
weidu=
#stty -F /dev/ttyUSB2 speed 115200

echo -en "AT+FGGPSSTOP\r" > /dev/ttyUSB2
sleep 1
echo -en "AT+FGGPSINIT\r" > /dev/ttyUSB2
sleep 1
echo -en "AT+FGGPSMODE=1,0,25,6,0\r" > /dev/ttyUSB2
sleep 1
echo -en "AT+FGGPSRUN\r" > /dev/ttyUSB2

getdata(){
while true 
do
cat /dev/ttyUSB3 > /tmp/gps &
sleep 10
killall cat
jindu=`cat /tmp/gps |grep -i gpgga |tail -n 1 |cut -d, -f3`
if [ -z "$jindu" ];then 
   echo "can't get location"
  else
  weidu=`cat /tmp/gps |grep -i gpgga |tail -n 1 |cut -d, -f5`
  break
fi
done
}

getdata
du1=${jindu:0:2}
fen1=${jindu:2:9}
du2=${weidu:0:3}
fen2=${weidu:3:9}
new_jindu=`echo| awk -v x=$fen1 -v y=$du1 '{printf("%.6f", y+x/60)}'`
new_weidu=`echo| awk -v x=$fen2 -v y=$du2 '{printf("%.6f",y+x/60)}'`
echo "$new_jindu,$new_weidu"
uci -q set gps.loc.jingdu=$new_jindu
uci -q set gps.loc.weidu=$new_weidu
uci commit gps


 







#!/bin/sh

if [ ! -d "/sys/class/gpio/gpio11" ];then
{
echo 11 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio11/direction
}
fi

status=`cat /sys/class/gpio/gpio11/value`
#echo $status
if [[ $status == "1" ]];then
{
echo 0 > /sys/class/gpio/gpio11/value
#cat /sys/class/gpio/gpio11/value
}
else
{
echo 1  > /sys/class/gpio/gpio11/value
#cat /sys/class/gpio/gpio11/value
}
fi

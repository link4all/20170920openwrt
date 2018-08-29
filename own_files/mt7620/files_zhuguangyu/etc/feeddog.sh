#!/bin/sh

if [ ! -d "/sys/class/gpio/gpio30/" ];then
{
echo "gpio30 not enabled!"
echo 30 >/sys/class/gpio/export
echo out >/sys/class/gpio/gpio30/direction
}
else
{
echo "gpio30 enabled"
}
fi
if [ ! -d "/sys/class/gpio/gpio31/" ];then
{
echo "gpio31 not enabled!"
echo 31 >/sys/class/gpio/export
echo out >/sys/class/gpio/gpio31/direction
}
else
{
echo "gpio31 enabled"
}
fi
while true 
do 
    echo 1 >/sys/class/gpio/gpio30/value
    echo 1 >/sys/class/gpio/gpio31/value
    sleep 1
    echo 0 >/sys/class/gpio/gpio30/value
    echo 0 >/sys/class/gpio/gpio31/value
    sleep 1
 #   echo "feeddog OK!"
done


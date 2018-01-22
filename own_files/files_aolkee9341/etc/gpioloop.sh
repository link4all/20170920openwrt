#!/bin/sh

if [ -f /sys/class/gpio/gpio12/value ];then
echo gpio12 ok
else
echo 12 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio12/direction
echo 1 > /sys/class/gpio/gpio12/value

if [ -f /sys/class/gpio/gpio15/value ];then
echo gpio15 ok
else
echo 15 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio15/direction
echo 0 > /sys/class/gpio/gpio15/value

while true 
do
echo 0 > /sys/class/gpio/gpio12/value
sleep 1
echo 1 > /sys/class/gpio/gpio12/value
sleep 1
done


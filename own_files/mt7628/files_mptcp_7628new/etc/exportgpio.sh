#!/bin/sh

for i in 0 1 2 3 
do
echo $i > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio${i}/direction
echo 0 > /sys/class/gpio/gpio${i}/value
done

#insmod i2c-gpio-custom bus0=0,5,4

sleep 1

for i in 0 1 2 3 
do
echo 1 > /sys/class/gpio/gpio${i}/value
done


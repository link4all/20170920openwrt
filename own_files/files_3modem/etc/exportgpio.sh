#!/bin/sh

for i in 0 1 2 3 4 5 11
do
echo $i > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio${i}/direction
echo 0 > /sys/class/gpio/gpio${i}/value
done

sleep 1

for i in 0 1 2 3 4 5 11
do
echo 1 > /sys/class/gpio/gpio${i}/value
done


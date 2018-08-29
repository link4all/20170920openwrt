#!/bin/sh


echo 3 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio3/direction
echo 0 > /sys/class/gpio/gpio3/value


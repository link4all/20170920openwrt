#!/bin/sh

V1=`i2cget -y 0 0x3c 0x14`
V2=`i2cget -y 0 0x3c 0x15`
Vbat=$((((($V2 & 0x0F)<<8)+$V1)*12/10))
awk -v x=$Vbat 'BEGIN{printf "Voltage is: %.3fV\n",x/1000}'
percent=`i2cget -y 0 0x3c 0x4F`
echo "Power remains :$(($percent))%"

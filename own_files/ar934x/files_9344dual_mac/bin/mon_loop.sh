#!/bin/sh

while true; do
  for i in `seq 1 11`;do
    #echo $i
    iw phy phy0  set channel $i
    #sleep 1
  done
done

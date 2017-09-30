#!/bin/sh

mpath=`cat /etc/play/mpath`
madplay /mnt/mmcblk0p1/${mpath}/$1&


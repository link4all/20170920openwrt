#!/bin/sh

init_led()
 {
  echo 14 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio14/direction
  echo 0 > /sys/class/gpio/gpio14/active_low
  echo 1 > /sys/class/gpio/gpio14/value

  echo 15 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio15/direction
  echo 0 > /sys/class/gpio/gpio15/active_low
  echo 1 > /sys/class/gpio/gpio15/value

  echo 16 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio16/direction
  echo 0 > /sys/class/gpio/gpio16/active_low
  echo 1 > /sys/class/gpio/gpio16/value

  echo 17 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio17/direction
  echo 0 > /sys/class/gpio/gpio17/active_low
  echo 1 > /sys/class/gpio/gpio17/value

  echo 18 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio18/direction
  echo 0 > /sys/class/gpio/gpio18/active_low
  echo 1 > /sys/class/gpio/gpio18/value

  echo 19 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio19/direction
  echo 0 > /sys/class/gpio/gpio19/active_low
  echo 1 > /sys/class/gpio/gpio19/value

  echo 20 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio20/direction
  echo 0 > /sys/class/gpio/gpio20/active_low
  echo 1 > /sys/class/gpio/gpio20/value

  echo 21 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio21/direction
  echo 0 > /sys/class/gpio/gpio21/active_low
  echo 1 > /sys/class/gpio/gpio21/value

}

init_led

mpath=`cat /etc/play/mpath`
. /etc/setled.sh
write${mpath}

#!/bin/sh

#²âÊÔÖĞÎÄ
. /etc/disp.lib
initx
delayms 5

update_once

while  true ; do
  update_timer
done

#!/bin/sh

. /lib/functions.sh
mtd_art="/dev/mtd$(find_mtd_index art)"

# read -p "Please input you MAC: " mac
# echo -ne "\x${mac//:/\\x}" > /tmp/mac
echo -ne "\x$1\x$2\x$3\x$4\x$5\x$6" > /tmp/mac

dd if=$mtd_art of=/tmp/art.bin
dd if=/tmp/mac of=/tmp/art.bin bs=1 seek=4098 count=6  conv=notrunc
mtd erase $mtd_art
dd if=/tmp/art.bin of=$mtd_art

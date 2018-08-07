#!/bin/sh
if grep "CONFIG_TARGET_ramips=y" .config; then 
rm -rf './build_dir/target-mips_34kc_uClibc-0.9.33.2/linux-ar71xx_generic/base-files' 
fi
if grep "CONFIG_TARGET_ar71xx=y" .config; then 
rm -rf './build_dir/target-mipsel_24kec+dsp_uClibc-0.9.33.2/linux-ramips_mt7688/base-files' 
fi


time make V=s -j8

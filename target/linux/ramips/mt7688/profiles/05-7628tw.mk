#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/7628tw
	NAME:=7628tw
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci \
		kmod-ledtrig-netdev \
        	maccalc 
endef

define Profile/7628tw/Description
	7628tw base packages.
endef
$(eval $(call Profile,7628tw))

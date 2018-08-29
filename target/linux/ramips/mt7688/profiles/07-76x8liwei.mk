#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/76x8liwei
	NAME:=76x8liwei
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci \
		kmod-ledtrig-netdev \
        	maccalc 
endef

define Profile/76x8liwei/Description
	76x8liwei base packages.
endef
$(eval $(call Profile,76x8liwei))

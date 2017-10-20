#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/mtb
	NAME:=mtb
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci \
		kmod-ledtrig-netdev \
        	maccalc 
endef

define Profile/mtb/Description
	mtb base packages.
endef
$(eval $(call Profile,mtb))

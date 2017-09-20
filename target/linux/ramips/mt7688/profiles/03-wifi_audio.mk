#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/wifi_audio
	NAME:=wifi_audio
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci \
		kmod-ledtrig-netdev \
        	maccalc reg
endef

define Profile/wifi_audio/Description
	wifi_audio base packages.
endef
$(eval $(call Profile,wifi_audio))

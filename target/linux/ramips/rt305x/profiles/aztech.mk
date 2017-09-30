#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/HW550-3G
	NAME:=Aztech HW550-3G
	PACKAGES:=\
		kmod-usb-core kmod-usb-dwc2 \
		kmod-ledtrig-usbdev
endef

define Profile/HW550-3G/Description
	Package set for Aztech HW550-3G
endef

$(eval $(call Profile,HW550-3G))

define Profile/AIR3GII
	NAME:=Aztech AIR3GII
	PACKAGES:=\
		kmod-usb-core kmod-usb-dwc2 \
		kmod-ledtrig-usbdev
endef

define Profile/AIR3GII/Description
	Package set for Aztech AIR3GII
endef

$(eval $(call Profile,AIR3GII))

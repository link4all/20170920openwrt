
#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

#PKG_NAME:=gobinet

PKG_VERSION:=1
PKG_RELEASE:=1

#PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/gobinet
PKG_UNPACK=mkdir -p $(PKG_BUILD_DIR); \
$(CP) -r ./driver_fangge/ $(PKG_BUILD_DIR)/; \
$(CP) -r ./driver_yiyuan/ $(PKG_BUILD_DIR)/;\
$(CP) -r ./driver_xinfeng/ $(PKG_BUILD_DIR)/

include $(INCLUDE_DIR)/package.mk

define KernelPackage/usb-net-gobinet_fg
  SUBMENU:=USB Support
  TITLE:=usb-net-gobinet_fg for qca9x07
  DEPENDS:= +kmod-usb-net
  FILES:=$(PKG_BUILD_DIR)/gobinet_fg.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,gobinet_fg)
endef

define KernelPackage/usb-net-gobinet_fg/description
usb-net-gobinet_fg for qca9x07
endef

define KernelPackage/usb-net-gobinet_yy
  SUBMENU:=USB Support
  TITLE:=usb-net-gobinet_yy for qca9x07
  DEPENDS:= +kmod-usb-net
  FILES:=$(PKG_BUILD_DIR)/gobinet_yy.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,gobinet_yy)
endef

define KernelPackage/usb-net-gobinet_yy/description
usb-net-gobinet_yy for qca9x07
endef

define KernelPackage/usb-net-gobinet_xy
  SUBMENU:=USB Support
  TITLE:=usb-net-gobinet_xy for qca9x07
  DEPENDS:= +kmod-usb-net
  FILES:=$(PKG_BUILD_DIR)/gobinet_xy.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,gobinet_xy)
endef

define KernelPackage/usb-net-gobinet_xy/description
usb-net-gobinet_xy for qca9x07
endef

SOURCE_DIR:=$(PKG_BUILD_DIR)
export SOURCE_DIR

MAKEOPTS1:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)/driver_fangge/" \
		CONFIG_USB_NET_GOBINET=m \
		modules
MAKEOPTS2:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)/driver_yiyuan" \
		CONFIG_USB_NET_GOBINET=m \
		modules
MAKEOPTS3:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)/driver_xinfeng" \
		CONFIG_USB_NET_GOBINET=m \
		modules

define Build/Compile
	$(MAKE) $(MAKEOPTS1)
	$(CP) $(PKG_BUILD_DIR)/driver_fangge/gobinet_fg.ko $(PKG_BUILD_DIR) 
	$(MAKE) $(MAKEOPTS2)
	$(CP) $(PKG_BUILD_DIR)/driver_yiyuan/gobinet_yy.ko $(PKG_BUILD_DIR) 
	$(MAKE) $(MAKEOPTS3)
	$(CP) $(PKG_BUILD_DIR)/driver_xinfeng/gobinet_xy.ko $(PKG_BUILD_DIR)
endef


$(eval $(call KernelPackage,usb-net-gobinet_fg))
$(eval $(call KernelPackage,usb-net-gobinet_yy))
$(eval $(call KernelPackage,usb-net-gobinet_xy))


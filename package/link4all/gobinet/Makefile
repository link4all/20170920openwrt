
#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=gobinet

PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=mkdir -p $(PKG_BUILD_DIR); $(CP) ./driver/* $(PKG_BUILD_DIR)/

include $(INCLUDE_DIR)/package.mk

define KernelPackage/usb-net-gobinet
  SUBMENU:=USB Support
  TITLE:=usb-net-gobinet for qca9x07
  DEPENDS:= +kmod-usb-net
  FILES:=$(PKG_BUILD_DIR)/gobinet.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,gobinet)
endef

define KernelPackage/usb-net-gobinet/description
usb-net-gobinet for qca9x07
endef

SOURCE_DIR:=$(PKG_BUILD_DIR)
export SOURCE_DIR

MAKEOPTS:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)" \
		CONFIG_USB_NET_GOBINET=m \
		modules

define Build/Compile
	$(MAKE) $(MAKEOPTS)
endef

define KernelPackage/usb-net-gobinet/install
endef

$(eval $(call KernelPackage,usb-net-gobinet))


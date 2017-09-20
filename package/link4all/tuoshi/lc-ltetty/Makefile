
#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lc-ltetty

PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=mkdir -p $(PKG_BUILD_DIR); $(CP) ./src/* $(PKG_BUILD_DIR)/

include $(INCLUDE_DIR)/package.mk

define KernelPackage/lc-ltetty
  SUBMENU:=USB Support
  TITLE:=lte_leadcore support Leadcore/tuoshi 4g modem
  DEPENDS:= +kmod-usb-serial
  FILES:=$(PKG_BUILD_DIR)/lc-ltetty.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,lc-ltetty)
endef

define KernelPackage/lc-ltetty/description
lc-ltetty support for  Leadcore/tuoshi 4g modem
endef

SOURCE_DIR:=$(PKG_BUILD_DIR)
export SOURCE_DIR

MAKEOPTS:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)" \
		CONFIG_LC-LTETTY=m \
		modules

define Build/Compile
	$(MAKE) $(MAKEOPTS)
endef

define KernelPackage/lc-ltetty/install
endef

$(eval $(call KernelPackage,lc-ltetty))

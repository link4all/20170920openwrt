
#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=cdc-encap

PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=mkdir -p $(PKG_BUILD_DIR); $(CP) ./src/* $(PKG_BUILD_DIR)/

include $(INCLUDE_DIR)/package.mk

define KernelPackage/cdc-encap
  SUBMENU:=USB Support
  TITLE:=cdc-encap support ZTE 3760
  DEPENDS:= +kmod-usb-net 
  FILES:=$(PKG_BUILD_DIR)/cdc_encap.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,cdc-encap)
endef

define KernelPackage/cdc-encap/description
cdc-encap support for ZTE 3760
endef

SOURCE_DIR:=$(PKG_BUILD_DIR)
export SOURCE_DIR

MAKEOPTS:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)" \
		CONFIG_CDC_ENCAP=m \
		modules

define Build/Compile
	$(MAKE) $(MAKEOPTS)
endef

define KernelPackage/cdc-encap/install
endef

$(eval $(call KernelPackage,cdc-encap))

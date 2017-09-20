#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ar8035_phy

PKG_REV:=150316
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=6

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define KernelPackage/ar8035_phy
#  CATEGORY:=ar8035

  SECTION:=ar8035
  CATEGORY:=LINK4ALL
  TITLE:=ethernet 10/100/1000M ar8035_phy
  FILES:=$(PKG_BUILD_DIR)/ar8035/athrs_gmac.ko

  AUTOLOAD:=$(call AutoLoad,50,athrs_gmac)
endef

define KernelPackage/ar8035_phy/description
 This package contains a ar8035_phy driver
endef

define KernelPackage/ar8035_phy/config
	source "$(SOURCE)/config.in"
endef

SOURCE_DIR:=$(PKG_BUILD_DIR)
export SOURCE_DIR




MAKEOPTS:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)/ar8035" \
                EXTRA_CFLAGS="-I $(PKG_BUILD_DIR)/ar8035/include -I $(PKG_BUILD_DIR)/ar8035/include/phys -I$(LINUX_DIR)/arch/mips/include -I $(PKG_BUILD_DIR)/ar8035/include/asm"
#                CONFIG_AR8035=m \
		modules

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) -r files/. $(PKG_BUILD_DIR)

endef



define Build/Compile
	$(MAKE) $(MAKEOPTS)
endef


$(eval $(call KernelPackage,ar8035_phy))

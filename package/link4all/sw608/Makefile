
#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=sw608

PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=mkdir -p $(PKG_BUILD_DIR); $(CP) ./src/* $(PKG_BUILD_DIR)/

include $(INCLUDE_DIR)/package.mk

define KernelPackage/sw608
  SECTION:=sw608
  CATEGORY:=LINK4ALL
  TITLE:=sw608 for mt7688/mt7628
  FILES:=$(PKG_BUILD_DIR)/sw608.ko
  AUTOLOAD:=$(call AutoLoad,AutoProbe,sw608)
endef

define KernelPackage/sw608/description
   sw608 for mt7688/mt7628
endef

SOURCE_DIR:=$(PKG_BUILD_DIR)
export SOURCE_DIR

MAKEOPTS:= -C $(LINUX_DIR) \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                M="$(PKG_BUILD_DIR)" \
		CONFIG_SW608=m \
		modules

define Build/Compile
	$(MAKE) $(MAKEOPTS)
endef

define KernelPackage/sw608/install
endef

$(eval $(call KernelPackage,sw608))


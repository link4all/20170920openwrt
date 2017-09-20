# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=4gdialer
PKG_VERSION:=0.01
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/4gdialer

include $(INCLUDE_DIR)/package.mk

define Package/4gdialer
  SECTION:=utils
  CATEGORY:=LINK4ALL
  DEPENDS:=+libpthread 
  TITLE:=4G modem dialer
endef

define Package/4gdialer/description
 4G modem rndis dialer
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/4gdialer/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/4gdialer $(1)/bin/
endef

$(eval $(call BuildPackage,4gdialer))

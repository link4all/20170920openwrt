#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flood_test
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/flood_test
        SECTION:=flood_test
        CATEGORY:=LINK4ALL
        DEPENDS:= +libpcap +libpthread 
        TITLE:=flood_test

endef

define Package/flood_test/description
	flood_test
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef


define Package/flood_test/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/collection_packet $(1)/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifi_probe_req_flood $(1)/bin/
endef

$(eval $(call BuildPackage,flood_test))


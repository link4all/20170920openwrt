#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qqnas
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/qqnas
        SECTION:=qqnas
        CATEGORY:=LINK4ALL
        DEPENDS:= +libstdcpp  +libpthread  +librt  +libopenssl 
        TITLE:=QQ IOT NAS

endef

define Package/qqnas/description
	QQ NAS demo form open.iot.qq.com.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./qq_iot/* $(PKG_BUILD_DIR)/
endef


define Package/qqnas/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_DIR) $(1)/lib/
	$(CP) ./files/etc/* $(1)/etc/
	$(CP) ./files/lib/* $(1)/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libnassdk.so $(1)/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qqnas $(1)/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qq_license $(1)/bin/
endef

$(eval $(call BuildPackage,qqnas))


#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=webwifi
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/webwifi
	SECTION:=webwifi
	CATEGORY:=LINK4ALL
	TITLE:=setwifi by web
#DEPENDS :=+luci
endef

define Package/webwifi/description
	This package provides  UCI for wifi Configuration.
endef

define Build/Prepare
        echo
endef

define Build/Compile
        echo
endef

define Package/webwifi/install
	$(INSTALL_DIR) $(1)/www/
	$(CP) ./files/www/* $(1)/www/
endef

$(eval $(call BuildPackage,webwifi))


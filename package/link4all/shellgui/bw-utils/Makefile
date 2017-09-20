#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bw-utils
PKG_VERSION:=$(GARGOYLE_VERSION)
ifeq ($(GARGOYLE_VERSION),)
     PKG_VERSION:=1.0.0
endif
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/bw-utils

include $(INCLUDE_DIR)/package.mk

define Package/bw-utils
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+iptables-mod-bandwidth
	TITLE:=Bandwidth utils
endef


define Package/bw-utils/description
  Bandwidth utils
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef


define Build/Configure
endef

define Build/Compile
	-$(MAKE) -C $(PKG_BUILD_DIR) clean
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		CFLAGS="$(TARGET_CFLAGS) -I $(STAGING_DIR)/usr/include" \
		LDFLAGS="$(TARGET_LDFLAGS) -L $(STAGING_DIR)/usr/lib" \
		all
	
	mkdir -p $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/*.h $(STAGING_DIR)/usr/include/

	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/*.so* $(STAGING_DIR)/usr/lib/
	
	$(MAKE) -C $(PKG_BUILD_DIR)/utils \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		CFLAGS="$(TARGET_CFLAGS) -I $(STAGING_DIR)/usr/include" \
		LDFLAGS="$(TARGET_LDFLAGS) -L $(STAGING_DIR)/usr/lib" \
		all
endef



define Package/bw-utils/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/*.so* $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/bw_get $(1)/usr/bin/bw-gain
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/bw_set $(1)/usr/bin/bw-padding
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/bw_print_history_file $(1)/usr/bin/bw-history
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/set_kernel_timezone $(1)/usr/bin/s-k-t
endef


$(eval $(call BuildPackage,bw-utils))


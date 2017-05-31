include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ser2net
PKG_VERSION=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-ser2net
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=ser2net for LuCI
	PKGARCH:=all
endef

define Package/luci-app-ser2net/description
	This package contains LuCI configuration pages for ser2net.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-ser2net/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller

	$(INSTALL_CONF) ./files/root/etc/config/ser2net $(1)/etc/config/ser2net
	$(INSTALL_BIN) ./files/root/etc/init.d/ser2net $(1)/etc/init.d/ser2net
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/ser2net.lua $(1)/usr/lib/lua/luci/model/cbi/ser2net.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/ser2net.lua $(1)/usr/lib/lua/luci/controller/ser2net.lua
endef

$(eval $(call BuildPackage,luci-app-ser2net))


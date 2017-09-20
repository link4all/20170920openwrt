# LuCI Material Theme
# Copyright 2015 Lutty Yang <lutty@wcan.in>
#
# Licensed under the Apache License v2.0
# http://www.apache.org/licenses/LICENSE-2.0

include $(TOPDIR)/rules.mk

THEME_NAME:=wfnt
THEME_TITLE:=wfnt

PKG_NAME:=luci-theme-wfnt
PKG_VERSION:=0.2.18
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-wfnt
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=4. Themes
  DEPENDS:=+libc
  TITLE:=LuCI Theme - wfnt
  PKGARCH:=all
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-theme-wfnt/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	echo "uci set luci.themes.wfnt=/luci-static/wfnt; uci commit luci" > $(1)/etc/uci-defaults/30-luci-theme-wfnt
	$(INSTALL_DIR) $(1)/www/luci-static/wfnt
	$(CP) -a ./files/* $(1)/ 2>/dev/null || true
endef

define Package/luci-theme-wfnt/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/30-luci-theme-wfnt && rm -f /etc/uci-defaults/30-luci-theme-wfnt
}
endef

$(eval $(call BuildPackage,luci-theme-wfnt))

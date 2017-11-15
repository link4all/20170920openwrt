OFFICIAL_VERSION:=1.9.X (Built 20171012-0221 git@ec0e1f0)
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk


PKG_NAME:=gargoyle-reduce
PKG_VERSION:=$(GARGOYLE_VERSION)
ifeq ($(GARGOYLE_VERSION),)
     PKG_VERSION:=1.0.0
endif
PKG_RELEASE:=6


PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gargoyle-reduce
	SECTION:=admin
	CATEGORY:=Administration
	TITLE:=gargoyle reduced
	DEPENDS:=+uci +libuci +haserl-i18n +uhttpd   +libericstools
	MAINTAINER:=Eric Bishop <eric@gargoyle-router.com>
endef

define Package/gargoyle-reduce/description
	A  reduced gargoyle
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		CFLAGS="$(TARGET_CFLAGS) -I $(STAGING_DIR)/usr/include" \
		LDFLAGS="$(TARGET_LDFLAGS) -L $(STAGING_DIR)/usr/lib" 
endef

define Package/gargoyle-reduce/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
	mkdir -p $(1)/www/data/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gargoyle_session_validator $(1)/usr/bin
endef



$(eval $(call BuildPackage,gargoyle-reduce))

OFFICIAL_VERSION:=1.9.X (Built 20171012-0221 git@ec0e1f0)
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk


PKG_NAME:=plugin-ss
PKG_VERSION:=$(GARGOYLE_VERSION)
ifeq ($(GARGOYLE_VERSION),)
     PKG_VERSION:=1.0.0
endif
PKG_RELEASE:=6


PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/plugin-ss
	SECTION:=admin
	CATEGORY:=Administration
	SUBMENU:=gargoyle-plugins
	TITLE:=plugin-ss
	MAINTAINER:=david from link4all
endef

define Package/plugin-ss/description
	 plugin-ss
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile

endef

define Package/plugin-ss/install
	$(INSTALL_DIR) $(1)/www
	$(CP) $(PKG_BUILD_DIR)/www/* $(1)/www/ 
endef



$(eval $(call BuildPackage,plugin-ss))

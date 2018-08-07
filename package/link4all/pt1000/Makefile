include $(TOPDIR)/rules.mk

PKG_NAME:=pt1000
PKG_VERSION:=1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/pt1000/default
	SECTION:=net
	CATEGORY:=Link4all
	TITLE:=pt1000 platform client tool
    DEPENDS:= +libpthread
endef

define Package/pt1000
	$(call Package/pt1000/default)
	VARIANT:=nossl
endef

define Package/pt1000/description
	pt1000 platform client tools
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp src/* $(PKG_BUILD_DIR)
	$(Build/Path)
endef

TARGET_LDFLAGS += -lpthread

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/$(PKG_NAME).o -c $(PKG_BUILD_DIR)/main.c
	$(TARGET_CC) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/$(1) $(PKG_BUILD_DIR)/$(PKG_NAME).o
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin
endef

$(eval $(call BuildPackage,pt1000))



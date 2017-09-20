include $(TOPDIR)/rules.mk
 
PKG_NAME:=socks5
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
 
include $(INCLUDE_DIR)/package.mk
 
define Package/socks5
    SECTION:=utils
    CATEGORY:=LINK4ALL
    DEPENDS:=+libpthread +libstdcpp
    TITLE:=socks5
endef
 
define Build/Prepare
	$(MKDIR) -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef
 
define Package/socks5/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/socks5 $(1)/bin
endef
 
$(eval $(call BuildPackage,socks5))

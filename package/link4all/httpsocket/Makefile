include $(TOPDIR)/rules.mk
 
PKG_NAME:=httpsocket
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
 
include $(INCLUDE_DIR)/package.mk
 
define Package/httpsocket
    SECTION:=utils
    CATEGORY:=LINK4ALL
#    DEPENDS:= +libstdcpp
    DEPENDS:= +libc
    TITLE:=httpsocket
endef
 
define Build/Prepare
	$(MKDIR) -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef
 
define Package/httpsocket/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/httpsocket $(1)/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./etc/init.d/httpsocket $(1)/etc/init.d
endef
 
$(eval $(call BuildPackage,httpsocket))

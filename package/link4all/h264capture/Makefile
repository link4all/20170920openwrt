include $(TOPDIR)/rules.mk
 
PKG_NAME:=h264capture
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
 
include $(INCLUDE_DIR)/package.mk
 
define Package/h264capture
    SECTION:=utils
    CATEGORY:=LINK4ALL
#    DEPENDS:= +libstdcpp
    DEPENDS:= +libc
    TITLE:=h264capture
endef
 
define Build/Prepare
	$(MKDIR) -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef
 
define Package/h264capture/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/h264capture $(1)/bin
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_BIN) ./etc/init.d/h264capture $(1)/etc/init.d
endef
 
$(eval $(call BuildPackage,h264capture))

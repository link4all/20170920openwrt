include $(TOPDIR)/rules.mk

PKG_NAME:=adbyby-save
PKG_VERSION:=2.7
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/adbyby-save
   SECTION:=net
   CATEGORY:=Network
   SUBMENU:=Routing and Redirection
   DEPENDS:=
   TITLE:=AD Bye Bye
   PKGARCH:=all
   USERID:=adbyby=45555:adbyby=45555
endef

define Package/adbyby-save/description
   ADBYBY is a tools to remove AD from internet browsing.
endef

define Build/Compile
endef

define Package/adbyby-save/install
	$(INSTALL_DIR) $(1)/opt/adbyby
	$(CP) ./files/bin/* $(1)/opt/adbyby
endef

$(eval $(call BuildPackage,adbyby-save))

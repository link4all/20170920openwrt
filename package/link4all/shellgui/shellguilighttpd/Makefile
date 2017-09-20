# shellguilighttpd的Makefile修改						用以和系统自带的shellguilighttpd分离
#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shellguilighttpd
PKG_VERSION:=1.4.37
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.shellguilighttpd.net/shellguilighttpd/releases-1.4.x
PKG_MD5SUM:=69660ab6c2c1d44c73904ee5a7591cb2

PKG_LICENSE:=BSD-3c
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shellguilighttpd/Default
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  URL:=http://www.shellguilighttpd.net/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/shellguilighttpd
  $(call Package/shellguilighttpd/Default)
  MENU:=1
  DEPENDS:=+shellguilighttpd_SSL:libopenssl +libpcre +libpthread
  TITLE:=A flexible and lightweight web server
endef

define Package/shellguilighttpd/config
config shellguilighttpd_SSL
	bool "SSL support"
	depends on PACKAGE_shellguilighttpd
	default y
	help
	  Implements SSL support in shellguilighttpd (using libopenssl). This
	  option is required if you enable the SSL engine in your
	  shellguilighttpd confguration file.
endef

CONFIGURE_ARGS+= \
	--bindir=/usr/shellgui/shellguilighttpd/bin \
	--sbindir=/usr/shellgui/shellguilighttpd/sbin \
	--libdir=/usr/shellgui/shellguilighttpd/lib \
	--sysconfdir=/usr/shellgui/etc/lighttpd \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--without-attr \
	--without-bzip2 \
	--without-fam \
	--without-gdbm \
	--without-ldap \
	--with-lua \
	--without-memcache \
	--with-pcre \
	--without-valgrind \
	 $(call autoconf_bool,CONFIG_IPV6,ipv6)

CONFIGURE_VARS+= \
	PCRE_LIB="-lpcre" \

ifneq ($(strip $(CONFIG_shellguilighttpd_SSL)),)
  CONFIGURE_ARGS+= \
	--with-openssl="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS+= \
	--without-openssl
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_shellguilighttpd-mod-mysql-vhost),)
  CONFIGURE_ARGS+= \
	--with-mysql
else
  CONFIGURE_ARGS+= \
	--without-mysql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_shellguilighttpd-mod-webdav),)
  CONFIGURE_ARGS+= \
	--with-webdav-locks \
	--with-webdav-props
  # XXX: needed by sqlite3 to prevent segfaults in mod_webdav.so
  CONFIGURE_VARS+= \
	LIBS="-lpthread"
else
  CONFIGURE_ARGS+= \
	--without-webdav-locks \
	--without-webdav-props
endif

define Build/Configure
$(call Build/Configure/Default)
	# XXX: override pcre (mis)detection by ./configure when cross-compiling
	echo "#define HAVE_LIBPCRE 1" >>$(PKG_BUILD_DIR)/config.h
	echo "#define HAVE_PCRE_H 1" >>$(PKG_BUILD_DIR)/config.h
endef

define Package/shellguilighttpd/conffiles
/usr/shellgui/shellguilighttpd/etc/lighttpd/lighttpd.conf
endef

define Package/shellguilighttpd/install
	$(INSTALL_DIR) $(1)/usr/shellgui/shellguilighttpd/etc/lighttpd
	$(INSTALL_DATA) ./files/lighttpd.conf $(1)/usr/shellgui/shellguilighttpd/etc/lighttpd/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/doc/config/conf.d/mime.conf $(1)/usr/shellgui/shellguilighttpd/etc/lighttpd/
	$(INSTALL_DIR) $(1)/usr/shellgui/shellguilighttpd/etc/lighttpd/conf.d
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shellguilighttpd.init $(1)/etc/init.d/shellguilighttpd
	$(INSTALL_DIR) $(1)/usr/shellgui/shellguilighttpd/lib
	for m in dirlisting indexfile staticfile; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/shellgui/shellguilighttpd/lib/mod_$$$${m}.so $(1)/usr/shellgui/shellguilighttpd/lib/ ; \
	done
	$(INSTALL_DIR) $(1)/usr/shellgui/shellguilighttpd/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/shellgui/shellguilighttpd/sbin/lighttpd $(1)/usr/shellgui/shellguilighttpd/sbin/shellguilighttpd
endef

define BuildPlugin
  define Package/shellguilighttpd-mod-$(1)
    $(call Package/shellguilighttpd/Default)
    DEPENDS:=shellguilighttpd
    ifneq ($(3),)
      DEPENDS+= $(3)
    endif
    TITLE:=$(2) module
  endef

  define Package/shellguilighttpd-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/shellgui/shellguilighttpd/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/shellgui/shellguilighttpd/lib/mod_$(1).so $$(1)/usr/shellgui/shellguilighttpd/lib
	$(INSTALL_DIR) $$(1)/usr/shellgui/shellguilighttpd/etc/lighttpd/conf.d
	if [ -f $(PKG_BUILD_DIR)/doc/config/conf.d/$(1).conf ]; then \
		$(CP) $(PKG_BUILD_DIR)/doc/config/conf.d/$(1).conf $$(1)/usr/shellgui/shellguilighttpd/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
	else \
		echo 'server.modules += ( "mod_$(1)" )' > $$(1)/usr/shellgui/shellguilighttpd/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
	fi
  endef

  $$(eval $$(call BuildPackage,shellguilighttpd-mod-$(1)))
endef

$(eval $(call BuildPackage,shellguilighttpd))

# First, permit redirect from HTTP to HTTPS.
$(eval $(call BuildPlugin,redirect,URL redirection,+PACKAGE_shellguilighttpd-mod-redirect:libpcre,10))

# Next, permit authentication.
$(eval $(call BuildPlugin,auth,Authentication,,20))

# Finally, everything else.
$(eval $(call BuildPlugin,access,Access restrictions,,30))
$(eval $(call BuildPlugin,accesslog,Access logging,,30))
$(eval $(call BuildPlugin,alias,Directory alias,,30))
$(eval $(call BuildPlugin,cgi,CGI,,30))
$(eval $(call BuildPlugin,cml,Cache Meta Language,+liblua,30))
$(eval $(call BuildPlugin,compress,Compress output,+PACKAGE_shellguilighttpd-mod-compress:zlib,30))
$(eval $(call BuildPlugin,evasive,Evasive,,30))
$(eval $(call BuildPlugin,evhost,Exnhanced Virtual-Hosting,,30))
$(eval $(call BuildPlugin,expire,Expire,,30))
$(eval $(call BuildPlugin,extforward,Extract client,,30))
$(eval $(call BuildPlugin,fastcgi,FastCGI,,30))
$(eval $(call BuildPlugin,flv_streaming,FLV streaming,,30))
$(eval $(call BuildPlugin,magnet,Magnet,+liblua,30))
$(eval $(call BuildPlugin,mysql_vhost,Mysql virtual hosting,+PACKAGE_shellguilighttpd-mod-mysql_vhost:libmysqlclient,30))
$(eval $(call BuildPlugin,proxy,Proxy,,30))
$(eval $(call BuildPlugin,rewrite,URL rewriting,+PACKAGE_shellguilighttpd-mod-rewrite:libpcre,30))
$(eval $(call BuildPlugin,rrdtool,RRDtool,,30))
$(eval $(call BuildPlugin,scgi,SCGI,,30))
$(eval $(call BuildPlugin,secdownload,Secure and fast download,,30))
$(eval $(call BuildPlugin,setenv,Environment variable setting,,30))
$(eval $(call BuildPlugin,simple_vhost,Simple virtual hosting,,30))
$(eval $(call BuildPlugin,ssi,SSI,+libpcre,30))
$(eval $(call BuildPlugin,status,Server status display,,30))
$(eval $(call BuildPlugin,trigger_b4_dl,Trigger before download,+PACKAGE_shellguilighttpd-mod-trigger_b4_dl:libpcre,30))
$(eval $(call BuildPlugin,userdir,User directory,,30))
$(eval $(call BuildPlugin,usertrack,User tracking,,30))
$(eval $(call BuildPlugin,webdav,WebDAV,+PACKAGE_shellguilighttpd-mod-webdav:libsqlite3 +PACKAGE_shellguilighttpd-mod-webdav:libuuid +PACKAGE_shellguilighttpd-mod-webdav:libxml2,30))

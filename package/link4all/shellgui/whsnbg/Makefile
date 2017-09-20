#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=whsnbg
PKG_VERSION:=1.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vladimir Alemasov <homewsn.com@gmail.com>

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

# Remote source
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/homewsn/whsnbg.git
PKG_SOURCE_VERSION:=HEAD
#PKG_SOURCE_VERSION:=68afbff6173024cb9299cf4e3c27ff5a831429cf
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz


PKG_BUILD_PARALLEL:=1

# Package dependencies
PKG_DPNDS:= +libc +libpthread
PKG_DPNDS+= +WHSNBG_AXTLS_LIBRARY:libaxtls +WHSNBG_OPENSSL_LIBRARY:libopenssl +(WHSNBG_SENSOR_DATA_MYSQL||WHSNBG_MQTT_DATA_MYSQL):libmysqlclient

# Package make flags
PKG_MFLAGS:= PREFIX=\".\"

ifneq ($(CONFIG_WHSNBG_DAEMON),)
  PKG_MFLAGS+= DAEMON_VERSION=1
endif
ifneq ($(CONFIG_WHSNBG_DPRINTF),)
  PKG_MFLAGS+= DETAILED_LOG=1
endif
ifneq ($(CONFIG_WHSNBG_RULES_ENGINE),)
  PKG_MFLAGS+= RULES_ENGINE=1
endif
ifneq ($(CONFIG_WHSNBG_AXTLS_LIBRARY),)
  PKG_MFLAGS+= TLS_LIB_AXTLS=1
endif
ifneq ($(CONFIG_WHSNBG_OPENSSL_LIBRARY),)
  PKG_MFLAGS+= TLS_LIB_OPENSSL=1
endif
ifneq ($(CONFIG_WHSNBG_SENSOR_DATA),)
  PKG_MFLAGS+= SENSOR_DATA_DECODING=1
endif
ifneq ($(CONFIG_WHSNBG_SENSOR_DATA_MYSQL),)
  PKG_MFLAGS+= SENSOR_DATA_STORING=1
endif
ifneq ($(CONFIG_WHSNBG_MQTT_DATA_MYSQL),)
  PKG_MFLAGS+= MQTT_DATA_STORING=1
endif
ifneq ($(CONFIG_WHSNBG_STATIC),)
  PKG_MFLAGS+= STATIC_LINK=1
endif
ifneq ($(CONFIG_WHSNBG_SENSOR_DATA_MYSQL),$(filter $(CONFIG_WHSNBG_MQTT_DATA_MYSQL),))
  PKG_MFLAGS+= LIBPATH=-L$(STAGING_DIR)/usr/lib/mysql
  PKG_MFLAGS+= INCLPATH=-I$(STAGING_DIR)/usr/include/mysql
endif

include $(INCLUDE_DIR)/package.mk

define Package/whsnbg/config
  source "$(SOURCE)/Config.in"
endef

define Package/whsnbg/default
  SECTION:=base
  CATEGORY:=Network
  URL:=http://www.homewsn.com/
endef

define Package/whsnbg
  $(Package/whsnbg/default)
  TITLE:=MQTT broker and rules engine, MQTT-SN gateway, MySQL WSN client
  DEPENDS:=$(PKG_DPNDS)
  MENU:=1
endef

define Package/whsnbg-cc2531-usb
  $(Package/whsnbg/default)
  DEFAULT:=n
  TITLE:=Whsnbg script files for cc2531 usb dongle
#  DEPENDS:=@USB_SUPPORT whsnbg +kmod-slip +kmod-usb-acm +net-tools-slattach
  DEPENDS:=whsnbg +kmod-slip +kmod-usb-acm +net-tools-slattach
endef

define Package/whsnbg/conffiles
/etc/whsnbg.conf
/etc/whsnbg.pem
endef

define Package/whsnbg-cc2531-usb/conffiles
/etc/init.d/cc2531slip
/etc/hotplug.d/usb/20-cc2531
endef

define Package/whsnbg/description
 This package provides a daemon which implements MQTT broker and simple
 MQTT rules engine, MQTT-SN gateway, and MySQL client for sensor networks.
endef

define Package/whsnbg-cc2531-usb/description
 This package provides script files to run whsnbg automatically
 when cc2531 dongle is connected.
endef

# Local source in ../whsnbg directory
#define Build/Prepare
#	mkdir -p $(PKG_BUILD_DIR)
#	$(CP) ../whsnbg/* $(PKG_BUILD_DIR)/
#endef

define Build/Compile
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_MFLAGS) -C $(PKG_BUILD_DIR)
endef

define Package/whsnbg/install
	$(INSTALL_DIR) $(1)/bin $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/whsnbg $(1)/bin/
	$(INSTALL_DATA) ./files/whsnbg.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/whsnbg.pem $(1)/etc/
endef

define Package/whsnbg-cc2531-usb/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/hotplug.d/usb
	$(INSTALL_BIN) ./files/cc2531slip $(1)/etc/init.d/
	$(INSTALL_DATA) ./files/20-cc2531 $(1)/etc/hotplug.d/usb/
endef

define Package/whsnbg-cc2531-usb/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
        echo "Enabling rc.d symlink for cc2531slip."
        /etc/init.d/cc2531slip enable
fi
exit 0
endef

define Package/whsnbg-cc2531-usb/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
        echo "Removing rc.d symlink for cc2531slip."
        /etc/init.d/cc2531slip disable
fi
exit 0
endef

$(eval $(call BuildPackage,whsnbg))
$(eval $(call BuildPackage,whsnbg-cc2531-usb))

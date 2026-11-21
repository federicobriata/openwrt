include $(TOPDIR)/rules.mk

PKG_NAME:=apup-watchdog
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/apup-watchdog-batman-iv
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Add APuP peers to batman-adv
  DEPENDS:=+kmod-batman-adv +batctl-default +kmod-macvlan +kmod-dummy +ip-full +iw
  PKGARCH:=all
  PROVIDES:=apup-watchdog
endef

define Package/apup-watchdog-batman-iv/description
 Service that watches the WDS interfaces hostapd creates for APuP peers
 and adds them to the bat0 batman-adv mesh interface through macvlan
 interfaces with unique MAC addresses, after a dummy primary0 interface.
endef

define Build/Compile
endef

define Package/apup-watchdog-batman-iv/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_BIN) ./files/apup-watchdog.sh $(1)/usr/sbin/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog.init $(1)/etc/init.d/apup-watchdog
endef

$(eval $(call BuildPackage,apup-watchdog-batman-iv))

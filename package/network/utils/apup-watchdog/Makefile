include $(TOPDIR)/rules.mk

PKG_NAME:=apup-watchdog
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/apup-watchdog-batman-iv
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Add APuP peers to batman-adv (BATMAN_IV)
  DEPENDS:=+kmod-batman-adv +batctl-default +kmod-macvlan +kmod-dummy +ip-full +iw
  PKGARCH:=all
  PROVIDES:=apup-watchdog
  CONFLICTS:=apup-watchdog-batman-v apup-watchdog-babel
endef

define Package/apup-watchdog-batman-iv/description
 Service that watches the WDS interfaces hostapd creates for APuP peers
 and adds them to the bat0 batman-adv mesh interface through macvlan
 interfaces with unique MAC addresses, after a dummy primary0 interface.
endef

define Package/apup-watchdog-batman-v
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Add APuP peers to batman-adv (BATMAN_V)
  DEPENDS:=+kmod-batman-adv @BATMAN_ADV_BATMAN_V +batctl-default
  PKGARCH:=all
  PROVIDES:=apup-watchdog
  CONFLICTS:=apup-watchdog-batman-iv apup-watchdog-babel
endef

define Package/apup-watchdog-batman-v/description
 Service that watches the WDS interfaces hostapd creates for APuP peers
 and adds them directly to the bat0 batman-adv mesh interface. bat0 must
 be created with routing_algo BATMAN_V in /etc/config/network.
endef

define Package/apup-watchdog-babel
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Add APuP peers to babeld
  DEPENDS:=+babeld +ip-tiny
  PKGARCH:=all
  PROVIDES:=apup-watchdog
  CONFLICTS:=apup-watchdog-batman-iv apup-watchdog-batman-v
endef

define Package/apup-watchdog-babel/description
 Service that watches the WDS interfaces hostapd creates for APuP peers,
 starts babeld on the first one and adds the others to it. The node
 address is the /32 that netifd keeps on lo.
endef

define Build/Compile
endef

define Package/apup-watchdog-batman-iv/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/apup-watchdog-batman-iv.sh $(1)/usr/sbin/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog.init $(1)/etc/init.d/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog-batman-iv.defaults $(1)/etc/uci-defaults/90_apup-watchdog
endef

define Package/apup-watchdog-batman-v/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/apup-watchdog-batman-v.sh $(1)/usr/sbin/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog.init $(1)/etc/init.d/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog-batman-v.defaults $(1)/etc/uci-defaults/90_apup-watchdog
endef

define Package/apup-watchdog-babel/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/apup-watchdog-babel.sh $(1)/usr/sbin/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog.init $(1)/etc/init.d/apup-watchdog
	$(INSTALL_BIN) ./files/apup-watchdog-babel.defaults $(1)/etc/uci-defaults/90_apup-watchdog
endef

$(eval $(call BuildPackage,apup-watchdog-batman-iv))
$(eval $(call BuildPackage,apup-watchdog-batman-v))
$(eval $(call BuildPackage,apup-watchdog-babel))

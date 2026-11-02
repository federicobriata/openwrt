include $(TOPDIR)/rules.mk

PKG_NAME:=batman-apup
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/batman-apup
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Add APuP peers to batman-adv
  DEPENDS:=+kmod-batman-adv +batctl-default
  PKGARCH:=all
endef

define Package/batman-apup/description
 Service that watches the WDS interfaces hostapd creates for APuP peers
 and adds them to the bat0 batman-adv mesh interface.
endef

define Build/Compile
endef

define Package/batman-apup/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_BIN) ./files/batman-apup.sh $(1)/usr/sbin/batman-apup-watchdog
	$(INSTALL_BIN) ./files/batman-apup.init $(1)/etc/init.d/batman-apup
endef

$(eval $(call BuildPackage,batman-apup))

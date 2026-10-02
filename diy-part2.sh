#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# ===== 1. 替换 PassWall 相关旧包 =====
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# 核心依赖库：固定 commit c1c015e
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
cd package/passwall-packages && git checkout c1c015e && cd ../..

# LuCI 界面：固定 tag 26.5.3-1
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci
cd package/passwall-luci && git checkout 26.5.3-1 && cd ../..

# ===== 2. 替换 Go 工具链 =====
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang

# 4. 应用 iptables-mod-socket 补丁
if [ -f "$GITHUB_WORKSPACE/0001-Add-iptables-socket.patch" ]; then
    patch -p1 -N < "$GITHUB_WORKSPACE/0001-Add-iptables-socket.patch" || true
    echo "iptables-mod-socket patch applied"
else
    echo "WARNING: 0001-Add-iptables-socket.patch not found"
fi

# 5. 修改 MTK Wi-Fi 默认 SSID 和密码
sed -i 's/ImmortalWrt-2.4G/666999/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/666999_/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/encryption=none/encryption=psk2/' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "/encryption=psk2/a\\\t\t\t\t\tset wireless.default_\${dev}.key=huiyin268" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

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

# 1. 删除会和 kenzok8 small 源冲突的上游包
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat

# 2. 替换 golang（用 sbwml 的 27.x）
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang

# 3. 修改 MTK Wi-Fi 默认 SSID 和密码
sed -i 's/ImmortalWrt-2.4G/666999/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/666999_/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/encryption=none/encryption=psk2/' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "/encryption=psk2/a\\\t\t\t\t\tset wireless.default_\${dev}.key=huiyin268" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# 4. 应用 iptables-mod-socket 补丁
if [ -f "$GITHUB_WORKSPACE/0001-Add-iptables-socket.patch" ]; then
    patch -p1 -N < "$GITHUB_WORKSPACE/0001-Add-iptables-socket.patch" || true
    echo "iptables-mod-socket patch applied"
else
    echo "WARNING: 0001-Add-iptables-socket.patch not found in $GITHUB_WORKSPACE"
fi

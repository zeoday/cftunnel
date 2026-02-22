#!/bin/bash
set -e

REPO="qingchencloud/cftunnel"
INSTALL_DIR="/usr/local/bin"

OS=$(uname -s | tr A-Z a-z)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

URL="https://github.com/$REPO/releases/latest/download/cftunnel_${OS}_${ARCH}.tar.gz"
echo "正在下载 cftunnel ($OS/$ARCH)..."
TMP=$(mktemp -d)
curl -fsSL "$URL" | tar xz -C "$TMP"
sudo install -m 755 "$TMP/cftunnel" "$INSTALL_DIR/cftunnel"
rm -rf "$TMP"
echo "cftunnel 已安装到 $INSTALL_DIR/cftunnel"
echo "运行 cftunnel init 开始配置"

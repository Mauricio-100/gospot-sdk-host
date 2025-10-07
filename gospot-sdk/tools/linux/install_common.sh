#!/bin/sh
# install_common.sh - multiplatform linux installer wrapper
set -eu
PKGS="curl wget git unzip tar htop"
if command -v apk >/dev/null 2>&1; then
  apk update; apk add --no-cache $PKGS
elif command -v apt-get >/dev/null 2>&1; then
  DEBIAN_FRONTEND=noninteractive apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y $PKGS
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y $PKGS
elif command -v pacman >/dev/null 2>&1; then
  pacman -S --noconfirm $PKGS
else
  echo "Package manager not detected. Install: $PKGS"
fi

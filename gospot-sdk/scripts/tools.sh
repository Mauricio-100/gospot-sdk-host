#!/bin/sh
# tools.sh - installer / mettre à jour le SDK et utilitaires sur la machine cible
# Detect package manager and install a list of recommended packages quietly
set -eu
PKGS="curl wget ca-certificates openssh-client git unzip tar coreutils"
echo "[gospot] Détection du gestionnaire de paquets..."
if command -v apk >/dev/null 2>&1; then
  echo "[gospot] apk detected (Alpine)."
  apk update >/dev/null 2>&1 || true
  for p in $PKGS; do apk add --no-cache $p >/dev/null 2>&1 || echo "[gospot] failed: $p"; done
elif command -v apt-get >/dev/null 2>&1; then
  echo "[gospot] apt detected (Debian/Ubuntu)."
  DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null 2>&1 || true
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $PKGS >/dev/null 2>&1 || echo "[gospot] apt install failed"
elif command -v dnf >/dev/null 2>&1; then
  echo "[gospot] dnf detected (Fedora/RHEL)."
  dnf install -y -q $PKGS >/dev/null 2>&1 || echo "[gospot] dnf install failed"
elif command -v pacman >/dev/null 2>&1; then
  echo "[gospot] pacman detected (Arch)."
  pacman -Sy --noconfirm $PKGS >/dev/null 2>&1 || echo "[gospot] pacman install failed"
elif command -v pkg >/dev/null 2>&1; then
  echo "[gospot] termux pkg detected."
  pkg install -y $PKGS >/dev/null 2>&1 || echo "[gospot] pkg install failed"
elif command -v brew >/dev/null 2>&1; then
  echo "[gospot] brew detected (macOS)."
  for p in $PKGS; do brew install $p >/dev/null 2>&1 || echo "[gospot] brew failed $p"; done
else
  echo "[gospot] Gestionnaire de paquets non reconnu. Installez manuellement: $PKGS"
fi
echo "[gospot] Installation recommandée terminée (vérifiez les erreurs ci-dessus)."

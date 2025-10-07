#!/usr/bin/env sh
#
# populate-sdk.sh
# Crée une arborescence SDK multi-plateforme, y place des scripts utilitaires,
# construit un tarball prêt à être servi (public/gospot-sdk-<ver>.tar.gz)
#
# Usage: sh populate-sdk.sh [version]
# Example: sh populate-sdk.sh 1.0.1
#
set -eu

# --------------------
# CONFIG
# --------------------
VER="${1-1.0.0}"
ROOT_DIR="$(pwd)"
PUBLIC_DIR="$ROOT_DIR/public"
SDK_DIR="$ROOT_DIR/gospot-sdk"
TS="$(date +%Y%m%d%H%M%S)"
OUT_FILENAME="gospot-sdk-${VER}.tar.gz"
OUT_PATH="$PUBLIC_DIR/$OUT_FILENAME"

# Tools we will include as small scripts or wrappers (not heavy binaries)
# You can edit this list to add/remove tools to include
echo "=== GoSpot SDK population script ==="

# --------------------
# Helper functions
# --------------------
info() { printf "\033[1;36m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }
ok() { printf "\033[1;32m[OK]\033[0m %s\n" "$*"; }

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

# --------------------
# Create structure
# --------------------
info "Nettoyage / création des dossiers..."
rm -rf "$SDK_DIR"
ensure_dir "$SDK_DIR"
ensure_dir "$SDK_DIR/bin"
ensure_dir "$SDK_DIR/scripts"
ensure_dir "$SDK_DIR/tools/linux"
ensure_dir "$SDK_DIR/tools/mac"
ensure_dir "$SDK_DIR/tools/termux"
ensure_dir "$SDK_DIR/tools/windows"
ensure_dir "$PUBLIC_DIR"

# --------------------
# Write core scripts
# --------------------

info "Création de scripts de base..."

cat > "$SDK_DIR/scripts/ssh.sh" <<'SH'
#!/bin/sh
# ssh.sh - create or show a SSH key pair (ed25519 preferred)
set -eu
KEY="$HOME/.ssh/gospot_key"
if [ -f "$KEY" ]; then
  echo "[gospot] Clé existante : $KEY"
  echo "Public key:"
  cat "${KEY}.pub" || true
  exit 0
fi
mkdir -p "$(dirname "$KEY")"
if command -v ssh-keygen >/dev/null 2>&1; then
  echo "[gospot] Génération d'une clé ed25519..."
  ssh-keygen -t ed25519 -f "$KEY" -N "" || ssh-keygen -t rsa -b 4096 -f "$KEY" -N ""
  echo "[gospot] Clé créée : $KEY"
  echo "Public key:"
  cat "${KEY}.pub"
else
  echo "[gospot] ssh-keygen introuvable. Installez openssh-client/openssh."
  exit 2
fi
SH
chmod 755 "$SDK_DIR/scripts/ssh.sh"

cat > "$SDK_DIR/scripts/sysinfo.sh" <<'SH'
#!/bin/sh
# sysinfo.sh - print OS, arch, CPU, memory, disk summary (POSIX)
set -eu
printf "OS: " && uname -a
if [ -f /etc/os-release ]; then
  printf "Distro: " && awk -F= '/^NAME=/{print $2}' /etc/os-release | tr -d '"'
fi
printf "Arch: " && uname -m
if command -v lscpu >/dev/null 2>&1; then
  echo "CPU:"
  lscpu | sed -n '1,6p'
fi
echo "Memory:"
if command -v free >/dev/null 2>&1; then free -h; else df -h /; fi
echo "Disk usage:"
df -h /
SH
chmod 755 "$SDK_DIR/scripts/sysinfo.sh"

cat > "$SDK_DIR/scripts/admin.sh" <<'SH'
#!/bin/sh
# admin.sh - small admin helpers demo (non destructif)
set -eu
echo "[gospot] Informations système"
sh "$PWD/sysinfo.sh" 2>/dev/null || true
echo
echo "[gospot] Processus liés au SSH (si présents):"
ps aux | grep -E 'sshd|ssh' | grep -v grep || true
echo
echo "[gospot] Fin admin."
SH
chmod 755 "$SDK_DIR/scripts/admin.sh"

cat > "$SDK_DIR/scripts/tools.sh" <<'SH'
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
SH
chmod 755 "$SDK_DIR/scripts/tools.sh"

cat > "$SDK_DIR/scripts/nettools.sh" <<'SH'
#!/bin/sh
# nettools.sh - quick network helper wrapper
set -eu
echo "[gospot] Vérification connectivité..."
ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "Network: OK" || echo "Network: NOK"
echo "Local IPs:"
if command -v ip >/dev/null 2>&1; then ip -4 -o addr show scope global | awk '{print $4}'; elif command -v ifconfig >/dev/null 2>&1; then ifconfig | awk '/inet /{print $2}'; fi
echo "Routes:"
if command -v ip >/dev/null 2>&1; then ip route; else netstat -rn; fi
SH
chmod 755 "$SDK_DIR/scripts/nettools.sh"

cat > "$SDK_DIR/scripts/monitor.sh" <<'SH'
#!/bin/sh
# monitor.sh - simple live stats (one-shot)
set -eu
echo "[gospot] Top CPU processes (5):"
ps aux --sort=-%cpu | head -n 6
echo
echo "[gospot] Disk usage:"
df -h | sed -n '1,6p'
echo
echo "[gospot] Memory usage (top):"
if command -v free >/dev/null 2>&1; then free -h | sed -n '1,4p'; fi
SH
chmod 755 "$SDK_DIR/scripts/monitor.sh"

cat > "$SDK_DIR/scripts/speedtest.sh" <<'SH'
#!/bin/sh
# speedtest.sh - wrapper for speedtest-cli (python)
set -eu
if command -v speedtest-cli >/dev/null 2>&1; then speedtest-cli --simple || true
elif command -v python3 >/dev/null 2>&1; then
  python3 -m pip install --user speedtest-cli >/dev/null 2>&1 || true
  python3 -m speedtest_cli --simple || python3 -m speedtest_cli || true
else
  echo "[gospot] Aucun outil speedtest trouvé. Installez python3 and pip."
fi
SH
chmod 755 "$SDK_DIR/scripts/speedtest.sh"

# --------------------
# Platform-specific helper scripts (installers)
# --------------------
info "Génération des helpers d'installation par plateforme..."

# linux installer (generic)
cat > "$SDK_DIR/tools/linux/install_common.sh" <<'SH'
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
SH
chmod 755 "$SDK_DIR/tools/linux/install_common.sh"

# mac installer
cat > "$SDK_DIR/tools/mac/install_common.sh" <<'SH'
#!/bin/sh
# mac install helper (uses Homebrew)
set -eu
if command -v brew >/dev/null 2>&1; then
  brew update
  brew install wget curl git htop
else
  echo "Homebrew not found. Visit https://brew.sh to install."
fi
SH
chmod 755 "$SDK_DIR/tools/mac/install_common.sh"

# termux installer
cat > "$SDK_DIR/tools/termux/install_common.sh" <<'SH'
#!/bin/sh
# termux install helper
set -eu
if command -v pkg >/dev/null 2>&1; then
  pkg update -y
  pkg install -y curl wget openssh git python
else
  echo "Termux 'pkg' not found."
fi
SH
chmod 755 "$SDK_DIR/tools/termux/install_common.sh"

# windows powershell helper (text file to copy)
cat > "$SDK_DIR/tools/windows/install_common.ps1" <<'PS'
# install_common.ps1 - Windows helper (PowerShell)
# Requires running in elevated session for choco install actions
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  Write-Host "Chocolatey not found. Follow https://chocolatey.org/install"
} else {
  choco install -y curl wget git
}
PS
chmod 755 "$SDK_DIR/tools/windows/install_common.ps1"

# --------------------
# small wrappers in bin/
# --------------------
info "Ajout de quelques wrappers utilitaires dans bin/ ..."

cat > "$SDK_DIR/bin/client.sh" <<'SH'
#!/bin/sh
# wrapper client.sh - call sdk scripts/client.sh if present
set -eu
BASE="$(cd "$(dirname "$0")/.." && pwd)/gospot-sdk || true
if [ -z "$BASE" ] || [ ! -d "$BASE" ]; then
  # fallback to local sdk folder (when installed in-place)
  BASE="$(dirname "$0")/.."
fi
if [ -x "$BASE/sdk/scripts/client.sh" ]; then
  exec "$BASE/sdk/scripts/client.sh" "$@"
else
  echo "[gospot] client.sh not found in SDK. Use scripts/client.sh from repo."
  exit 2
fi
SH
chmod 755 "$SDK_DIR/bin/client.sh"

cat > "$SDK_DIR/bin/server.sh" <<'SH'
#!/bin/sh
# wrapper server.sh
set -eu
BASE="$(cd "$(dirname "$0")/.." && pwd)/gospot-sdk || true
if [ -z "$BASE" ] || [ ! -d "$BASE" ]; then
  BASE="$(dirname "$0")/.."
fi
if [ -x "$BASE/sdk/scripts/server.sh" ]; then
  exec "$BASE/sdk/scripts/server.sh" "$@"
else
  echo "[gospot] server.sh not found in SDK."
  exit 2
fi
SH
chmod 755 "$SDK_DIR/bin/server.sh"

# create a sample client/server scripts (actual logic to implement later)
cat > "$SDK_DIR/sdk/scripts/client.sh" <<'SH'
#!/bin/sh
# sample client script - discovery placeholder
set -eu
echo "[gospot] This is a placeholder client script. Implement discovery logic here."
echo "Local IPs:"
if command -v ip >/dev/null 2>&1; then ip -4 -o addr show scope global | awk '{print $4}'; fi
SH
chmod 755 "$SDK_DIR/sdk/scripts/client.sh"

cat > "$SDK_DIR/sdk/scripts/server.sh" <<'SH'
#!/bin/sh
# sample server script - start hotspot/ssh placeholder
set -eu
echo "[gospot] This is a placeholder server script. Implement server logic here."
echo "[gospot] To provide connections, ensure sshd is runnable and hotspot enabled on device."
SH
chmod 755 "$SDK_DIR/sdk/scripts/server.sh"

# --------------------
# README + LICENSE
# --------------------
info "Rédaction README et LICENSE..."
cat > "$SDK_DIR/README.md" <<MD
# GoSpot SDK (auto-generated)

This SDK contains helper scripts to install and run GoSpot utilities across platforms.

Structure:
- bin/                : small wrappers
- scripts/            : core scripts (ssh, tools, admin, monitor...)
- tools/linux         : linux-specific installers
- tools/mac           : macOS helpers
- tools/termux        : Termux helpers
- tools/windows       : PowerShell helpers

Use \`tools.sh\` to bootstrap the target machine, or call specific scripts directly.
MD

cat > "$SDK_DIR/LICENSE" <<'TXT'
MIT License
Copyright (c) Mauricio
Permission is hereby granted...
TXT

# --------------------
# Final packaging
# --------------------
info "Packaging SDK to: $OUT_PATH"
# remove any old tarball
if [ -f "$OUT_PATH" ]; then rm -f "$OUT_PATH"; fi

# create tar.gz from gospot-sdk folder (we want only folder contents inside tar)
( cd "$SDK_DIR" && tar -czf "$OUT_PATH" . )
ok "Tarball créé: $OUT_PATH"

# --------------------
# Git (optional)
# --------------------
info "Ajout des fichiers dans git (optionnel)."
# copy tarball to public/ already done
# create commit that the user can push. We will not push automatically to avoid secrets overwrite.
if [ -d .git ]; then
  git add -A public/"$OUT_FILENAME" gospot-sdk
  git commit -m "chore: update gospot-sdk ($VER) - $(date -u +"%Y-%m-%d %H:%M:%SZ")" || warn "git commit failed or no changes"
  echo
  echo "[INFO] Commit ready. To push to remote, run:"
  echo "  git push origin main"
else
  echo "[INFO] No git repo detected here. Initialize git and push if you want:"
  echo "  git init; git add .; git commit -m 'init gospot-sdk'; git remote add origin <url>; git push -u origin main"
fi

ok "Populate finished. SDK available at: $OUT_PATH"

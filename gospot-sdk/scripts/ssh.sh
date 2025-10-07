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

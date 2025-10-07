#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Script pour créer et remplir la structure du SDK GoSpot
# Crée tous les dossiers manquants et des scripts de base

set -e

SDK_ROOT="$(pwd)/gospot-sdk"

echo "[INFO] Création des dossiers principaux..."
mkdir -p "$SDK_ROOT/bin"
mkdir -p "$SDK_ROOT/sdk/scripts"
mkdir -p "$SDK_ROOT/tools/linux"
mkdir -p "$SDK_ROOT/tools/mac"
mkdir -p "$SDK_ROOT/tools/termux"
mkdir -p "$SDK_ROOT/tools/windows"

echo "[INFO] Création des scripts binaires de base..."
touch "$SDK_ROOT/bin/client.sh"
touch "$SDK_ROOT/bin/server.sh"
chmod +x "$SDK_ROOT/bin/"*.sh

echo "[INFO] Création des scripts SDK de base..."
for script in admin.sh client.sh server.sh ssh.sh tools.sh sysinfo.sh monitor.sh nettools.sh speedtest.sh; do
    touch "$SDK_ROOT/sdk/scripts/$script"
    chmod +x "$SDK_ROOT/sdk/scripts/$script"
done

echo "[INFO] Création des scripts tools par plateforme..."
touch "$SDK_ROOT/tools/linux/install_common.sh"
touch "$SDK_ROOT/tools/mac/install_common.sh"
touch "$SDK_ROOT/tools/termux/install_common.sh"
touch "$SDK_ROOT/tools/windows/install_common.ps1"

chmod +x "$SDK_ROOT/tools/"*/install_common.sh 2>/dev/null || true

echo "[INFO] Ajout des fichiers README et LICENSE..."
touch "$SDK_ROOT/README.md"
touch "$SDK_ROOT/LICENSE"

echo "[✔] Structure SDK créée avec succès !"
echo "Tu peux maintenant remplir les fichiers avec tes scripts et outils réels."

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

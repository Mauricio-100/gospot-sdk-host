#!/bin/sh
# sample client script - discovery placeholder
set -eu
echo "[gospot] This is a placeholder client script. Implement discovery logic here."
echo "Local IPs:"
if command -v ip >/dev/null 2>&1; then ip -4 -o addr show scope global | awk '{print $4}'; fi

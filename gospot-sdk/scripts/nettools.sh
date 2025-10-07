#!/bin/sh
# nettools.sh - quick network helper wrapper
set -eu
echo "[gospot] Vérification connectivité..."
ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "Network: OK" || echo "Network: NOK"
echo "Local IPs:"
if command -v ip >/dev/null 2>&1; then ip -4 -o addr show scope global | awk '{print $4}'; elif command -v ifconfig >/dev/null 2>&1; then ifconfig | awk '/inet /{print $2}'; fi
echo "Routes:"
if command -v ip >/dev/null 2>&1; then ip route; else netstat -rn; fi

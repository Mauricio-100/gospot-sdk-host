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

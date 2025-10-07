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

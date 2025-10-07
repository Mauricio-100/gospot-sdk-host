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

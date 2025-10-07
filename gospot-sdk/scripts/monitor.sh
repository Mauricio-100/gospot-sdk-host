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

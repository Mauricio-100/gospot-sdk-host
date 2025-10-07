#!/bin/sh
# termux install helper
set -eu
if command -v pkg >/dev/null 2>&1; then
  pkg update -y
  pkg install -y curl wget openssh git python
else
  echo "Termux 'pkg' not found."
fi

#!/bin/sh
# mac install helper (uses Homebrew)
set -eu
if command -v brew >/dev/null 2>&1; then
  brew update
  brew install wget curl git htop
else
  echo "Homebrew not found. Visit https://brew.sh to install."
fi

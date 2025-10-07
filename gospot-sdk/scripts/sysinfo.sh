#!/bin/sh
# sysinfo.sh - print OS, arch, CPU, memory, disk summary (POSIX)
set -eu
printf "OS: " && uname -a
if [ -f /etc/os-release ]; then
  printf "Distro: " && awk -F= '/^NAME=/{print $2}' /etc/os-release | tr -d '"'
fi
printf "Arch: " && uname -m
if command -v lscpu >/dev/null 2>&1; then
  echo "CPU:"
  lscpu | sed -n '1,6p'
fi
echo "Memory:"
if command -v free >/dev/null 2>&1; then free -h; else df -h /; fi
echo "Disk usage:"
df -h /

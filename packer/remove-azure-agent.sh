#!/usr/bin/env bash
# Remove Azure Agent for hardening

set -euo pipefail

LOG="/var/log/remove-azure-agent.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Checking for walinuxagent..."

if systemctl is-active --quiet walinuxagent; then
  echo "[INFO] Stopping walinuxagent service..."
  systemctl stop walinuxagent
fi

if dpkg -l | grep -q walinuxagent; then
  echo "[INFO] Removing walinuxagent package..."
  apt-get remove -y walinuxagent
fi

if [ -d /var/lib/waagent ]; then
  echo "[INFO] Removing /var/lib/waagent directory..."
  rm -rf /var/lib/waagent
fi

echo "[INFO] Azure agent removed."
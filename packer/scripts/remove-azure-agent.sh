#!/usr/bin/env bash
# Remove Azure Linux Agent for security hardening

set -euo pipefail

LOG="/var/log/remove-azure-agent.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Checking if walinuxagent service is active..."

if systemctl is-active --quiet walinuxagent; then
  echo "[INFO] Stopping walinuxagent service..."
  systemctl stop walinuxagent
  echo "[INFO] Disabling walinuxagent service..."
  systemctl disable walinuxagent
fi

if dpkg -l | grep -qw walinuxagent; then
  echo "[INFO] Removing walinuxagent package..."
  apt-get remove -y walinuxagent
fi

if [ -d /var/lib/waagent ]; then
  echo "[INFO] Removing /var/lib/waagent directory..."
  rm -rf /var/lib/waagent
fi

echo "[INFO] Regenerating initramfs to reflect changes..."
update-initramfs -u

echo "[INFO] Azure Linux Agent removal complete."

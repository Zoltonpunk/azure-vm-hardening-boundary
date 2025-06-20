#!/usr/bin/env bash

set -euo pipefail

LOG="/var/log/packer-setup.log"
exec > >(tee -a "$LOG") 2>&1

echo "[SETUP] Running hardening..."
bash "$(dirname "$0")/hardening.sh"

echo "[SETUP] Removing Azure agent..."
bash "$(dirname "$0")/remove-azure-agent.sh"

echo "[SETUP] Installing Boundary and Apache..."
bash "$(dirname "$0")/install_boundary.sh"
bash "$(dirname "$0")/setup_apache_proxy.sh"

echo "[SETUP] All setup steps complete."
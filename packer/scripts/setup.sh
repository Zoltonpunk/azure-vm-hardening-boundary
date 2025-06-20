#!/usr/bin/env bash

set -euo pipefail

LOG="/var/log/packer-setup.log"
exec > >(tee -a "$LOG") 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "[SETUP] Running hardening..."
bash "$SCRIPT_DIR/hardening.sh"

echo "[SETUP] Removing Azure agent..."
bash "$SCRIPT_DIR/remove-azure-agent.sh"

echo "[SETUP] Installing Boundary and Apache..."
bash "$ROOT_DIR/Boundary/install_boundary.sh"
bash "$ROOT_DIR/Boundary/setup_apache_proxy.sh"

echo "[SETUP] All setup steps complete."

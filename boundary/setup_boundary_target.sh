#!/usr/bin/env bash
# setup_boundary_target.sh
# Creates a TCP target in Boundary pointing to the local Apache HTTPS server

set -euo pipefail

BOUNDARY_ADDR="http://127.0.0.1:9200"
export BOUNDARY_ADDR

# Create target
boundary targets create tcp \
  -name "Local Apache HTTPS" \
  -description "Dummy HTTPS Apache on localhost" \
  -default-port 443 \
  -address 127.0.0.1 \
  -format json

echo "[INFO] Boundary target created for 127.0.0.1:443"
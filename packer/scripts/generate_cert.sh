#!/usr/bin/env bash
# generate_cert.sh
# Generate a self-signed TLS certificate for localhost Apache server

set -euo pipefail

CERT_DIR="/etc/apache2/ssl"
DOMAIN="localhost"

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 365 \
  -subj "/C=US/ST=State/L=City/O=Org/OU=Unit/CN=$DOMAIN" \
  -newkey rsa:2048 \
  -keyout "$CERT_DIR/apache.key" \
  -out "$CERT_DIR/apache.crt"

chmod 600 "$CERT_DIR/apache.key"
echo "[INFO] Self-signed certificate created in $CERT_DIR"
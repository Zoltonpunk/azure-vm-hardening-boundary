#!/usr/bin/env bash
# Install HashiCorp Boundary (controller + worker) and iptables-persistent for firewall rules persistence

set -euo pipefail

LOG="/var/log/install_boundary.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Installing dependencies: unzip, wget, and iptables-persistent..."
apt-get update
apt-get install -y unzip wget iptables-persistent

BOUNDARY_VERSION="0.15.2"
BOUNDARY_ZIP="boundary_${BOUNDARY_VERSION}_linux_amd64.zip"
BOUNDARY_URL="https://releases.hashicorp.com/boundary/${BOUNDARY_VERSION}/${BOUNDARY_ZIP}"

echo "[INFO] Downloading Boundary version $BOUNDARY_VERSION..."
wget -q "$BOUNDARY_URL" -O "$BOUNDARY_ZIP"

echo "[INFO] Extracting Boundary binary..."
unzip -o "$BOUNDARY_ZIP"
mv -f boundary /usr/local/bin/
chmod 755 /usr/local/bin/boundary
rm -f "$BOUNDARY_ZIP"

echo "[INFO] Creating Boundary user and directories..."
if ! id -u boundary >/dev/null 2>&1; then
  useradd --system --home /etc/boundary --shell /bin/false boundary
fi

mkdir -p /etc/boundary /var/lib/boundary /var/log/boundary
chown -R boundary:boundary /etc/boundary /var/lib/boundary /var/log/boundary

echo "[INFO] Copying Boundary configuration..."
cp "$(dirname "$0")/boundary.hcl" /etc/boundary/boundary.hcl
chown boundary:boundary /etc/boundary/boundary.hcl

echo "[INFO] Creating systemd service for Boundary..."
cat > /etc/systemd/system/boundary.service <<EOF
[Unit]
Description=HashiCorp Boundary
After=network.target

[Service]
User=boundary
Group=boundary
ExecStart=/usr/local/bin/boundary server -config /etc/boundary/boundary.hcl
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "[INFO] Reloading systemd daemon and starting Boundary service..."
systemctl daemon-reload
systemctl enable boundary
systemctl start boundary

echo "[INFO] Saving current iptables rules for persistence..."
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4

echo "[INFO] Restarting netfilter-persistent service to apply saved rules..."
systemctl restart netfilter-persistent.service || true

echo "[INFO] Boundary installation and firewall persistence setup complete."

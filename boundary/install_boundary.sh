#!/usr/bin/env bash
# Install HashiCorp Boundary (controller+worker)

set -e

# Install dependencies
apt-get update
apt-get install -y unzip wget

# Download Boundary
BOUNDARY_VERSION="0.15.2"
wget https://releases.hashicorp.com/boundary/${BOUNDARY_VERSION}/boundary_${BOUNDARY_VERSION}_linux_amd64.zip
unzip boundary_${BOUNDARY_VERSION}_linux_amd64.zip
mv boundary /usr/local/bin/

# Create Boundary user and directories
useradd --system --home /etc/boundary --shell /bin/false boundary
mkdir -p /etc/boundary /var/lib/boundary /var/log/boundary
chown boundary:boundary /etc/boundary /var/lib/boundary /var/log/boundary

# Copy config (provide your own boundary.hcl)
cp $(dirname "$0")/boundary.hcl /etc/boundary/boundary.hcl
chown boundary:boundary /etc/boundary/boundary.hcl

# Setup systemd service for Boundary (controller+worker)
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

systemctl daemon-reload
systemctl enable boundary
systemctl start boundary

echo "Boundary installed and running."
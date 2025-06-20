#!/bin/bash
set -e


### Begin: hardening.sh ###
#!/usr/bin/env bash
# Run CIS Level 1 hardening with OpenSCAP

apt-get update
apt-get install -y openscap-scanner scap-security-guide

oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --results before_hardening.xml \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml

# Apply hardening steps (customize as needed)
# ...

oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --results after_hardening.xml \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
### End: hardening.sh ###

### Begin: install_boundary.sh ###
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
### End: install_boundary.sh ###

### Begin: setup_apache.sh ###
#!/usr/bin/env bash
# Install and configure Apache as a restrictive API reverse proxy

set -e

apt-get update
apt-get install -y apache2 openssl

# Generate a self-signed TLS cert
mkdir -p /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache.key \
    -out /etc/apache2/ssl/apache.crt \
    -subj "/CN=localhost"

# Enable Apache modules
a2enmod ssl proxy proxy_http headers

# Configure virtual host for reverse proxy (restrictive)
cat > /etc/apache2/sites-available/reverse-proxy.conf <<EOF
<VirtualHost *:443>
    ServerName localhost

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    ProxyPass /api http://localhost:9200/api
    ProxyPassReverse /api http://localhost:9200/api

    <Proxy *>
        Order deny,allow
        Deny from all
        Allow from 127.0.0.1
    </Proxy>
    RequestHeader set X-Forwarded-Proto "https"
</VirtualHost>
EOF

a2ensite reverse-proxy
a2dissite 000-default
systemctl reload apache2

echo "Apache reverse proxy set up and secured."
### End: setup_apache.sh ###

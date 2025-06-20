#!/usr/bin/env bash
# Install and configure Apache as a restrictive API reverse proxy with TLS

set -euo pipefail

LOG="/var/log/setup_apache_proxy.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Installing Apache and OpenSSL..."
apt-get update
apt-get install -y apache2 openssl

echo "[INFO] Generating self-signed TLS certificate..."
mkdir -p /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache.key \
    -out /etc/apache2/ssl/apache.crt \
    -subj "/CN=localhost"

echo "[INFO] Enabling Apache modules (ssl, proxy, proxy_http, headers)..."
a2enmod ssl proxy proxy_http headers

echo "[INFO] Configuring Apache virtual host for reverse proxy..."
cat > /etc/apache2/sites-available/reverse-proxy.conf <<EOF
<VirtualHost *:443>
    ServerName localhost

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    ProxyPass /api http://localhost:9200/api
    ProxyPassReverse /api http://localhost:9200/api

    <Proxy *>
        Require ip 127.0.0.1
    </Proxy>

    RequestHeader set X-Forwarded-Proto "https"
</VirtualHost>
EOF

echo "[INFO] Enabling reverse proxy site and disabling default site..."
a2ensite reverse-proxy
a2dissite 000-default

echo "[INFO] Reloading Apache to apply changes..."
systemctl reload apache2

echo "[INFO] Apache reverse proxy setup and secured successfully."

#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/setup_apache_proxy.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Installing Apache and OpenSSL..."
apt-get update
apt-get install -y apache2 openssl

echo "[INFO] Creating FQDN and TLS cert..."
FQDN="boundary.localdomain"
HOSTS_FILE="/etc/hosts"
CERT_DIR="/etc/apache2/ssl"

mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/apache.key" \
  -out "$CERT_DIR/apache.crt" \
  -subj "/CN=$FQDN"

if ! grep -q "$FQDN" "$HOSTS_FILE"; then
  echo "127.0.0.1 $FQDN dummy.localdomain" >> "$HOSTS_FILE"
fi

echo "[INFO] Enabling required Apache modules..."
a2enmod ssl proxy proxy_http headers

echo "[INFO] Configuring Apache reverse proxy to Boundary API..."
cat > /etc/apache2/sites-available/reverse-proxy.conf <<EOF
<VirtualHost *:443>
    ServerName $FQDN

    SSLEngine on
    SSLCertificateFile $CERT_DIR/apache.crt
    SSLCertificateKeyFile $CERT_DIR/apache.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:9200/
    ProxyPassReverse / http://localhost:9200/

    RequestHeader set X-Forwarded-Proto "https"

    <Location />
        Require all granted
    </Location>
</VirtualHost>
EOF

echo "[INFO] Creating dummy HTTPS service on localhost:8443..."
mkdir -p /var/www/html
echo "<h1>Dummy HTTPS Target</h1>" > /var/www/html/index.html

cat > /etc/apache2/sites-available/dummy.conf <<EOF
<VirtualHost 127.0.0.1:8443>
    ServerName dummy.localdomain
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile $CERT_DIR/apache.crt
    SSLCertificateKeyFile $CERT_DIR/apache.key

    <Directory /var/www/html>
        Require all granted
    </Directory>
</VirtualHost>
EOF

echo "[INFO] Enabling virtual hosts..."
a2ensite reverse-proxy
a2ensite dummy
a2dissite 000-default

echo "[INFO] Restarting Apache..."
systemctl reload apache2

echo "[INFO] Apache reverse proxy and dummy HTTPS setup complete."

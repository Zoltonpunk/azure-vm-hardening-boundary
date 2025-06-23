#!/usr/bin/env bash
# start_dummy_https.sh
# Configures Apache to use previously generated TLS cert and serve HTTPS content

set -euo pipefail

CERT_DIR="/etc/apache2/ssl"

# Create simple index.html if not exists
mkdir -p /var/www/html
if [ ! -f /var/www/html/index.html ]; then
  echo "<h1>Dummy HTTPS Server Running</h1>" > /var/www/html/index.html
fi

# Create Apache SSL site config
cat <<EOF > /etc/apache2/sites-available/dummy-https.conf
<VirtualHost *:443>
    ServerName localhost
    SSLEngine on
    SSLCertificateFile "$CERT_DIR/apache.crt"
    SSLCertificateKeyFile "$CERT_DIR/apache.key"

    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2enmod ssl
a2ensite dummy-https
systemctl reload apache2

echo "[INFO] Dummy HTTPS Apache server is running on https://localhost"
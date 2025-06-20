#!/usr/bin/env bash
# Enhanced CIS Level 1 hardening with OpenSCAP, custom hardening, and file permission lockdown

set -euo pipefail

LOG="/var/log/hardening.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Starting enhanced CIS Level 1 hardening..."

# Update package lists and install OpenSCAP tools
apt-get update
apt-get install -y openscap-scanner scap-security-guide

OSCAP_PROFILE="xccdf_org.ssgproject.content_profile_cis"
OSCAP_CONTENT="/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml"
REPORT_DIR="/var/log/hardening-reports"

mkdir -p "$REPORT_DIR"

# Check if the SCAP content file exists
if [ ! -f "$OSCAP_CONTENT" ]; then
  echo "[ERROR] OSCAP content not found at $OSCAP_CONTENT"
  exit 1
fi

# Run pre-hardening OpenSCAP scan to assess current system state
echo "[INFO] Running pre-hardening OpenSCAP scan..."
oscap xccdf eval \
  --profile "$OSCAP_PROFILE" \
  --results "$REPORT_DIR/pre_hardening_results.xml" \
  "$OSCAP_CONTENT"

# Run automatic remediation using OpenSCAP
echo "[INFO] Running automatic remediation..."
oscap xccdf eval \
  --profile "$OSCAP_PROFILE" \
  --remediate \
  "$OSCAP_CONTENT"

# -------------------------------
# Custom Hardening
# -------------------------------

echo "[INFO] Applying additional custom hardening..."

# Disable root SSH login
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Protect against IP spoofing
cat >> /etc/sysctl.d/99-custom.conf << EOF
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
sysctl --system

# Enable UFW with strict defaults
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# -------------------------------
# File Permission Lockdown
# -------------------------------

echo "[INFO] Hardening file permissions..."

# Set default umask to 027 (secure default)
echo "umask 027" >> /etc/profile
echo "umask 027" >> /etc/bash.bashrc

# Lock down /etc/shadow and /etc/gshadow
chmod 000 /etc/shadow /etc/gshadow
chown root:shadow /etc/shadow /etc/gshadow

# Remove world-writable permissions from all files (except /tmp, /var/tmp)
find / -xdev -type f -perm -0002 ! -path "/tmp/" ! -path "/var/tmp/" -exec chmod o-w {} \;

# Restrict user home directories to user-only access
for dir in /home/*; do
  if [ -d "$dir" ]; then
    chmod 700 "$dir"
  fi
done

# -------------------------------
# Final OpenSCAP Scan
# -------------------------------

echo "[INFO] Running post-hardening OpenSCAP scan..."
oscap xccdf eval \
  --profile "$OSCAP_PROFILE" \
  --results "$REPORT_DIR/post_hardening_results.xml" \
  "$OSCAP_CONTENT"

echo "[INFO] Hardening complete."
echo "[INFO] Reports saved in: $REPORT_DIR"

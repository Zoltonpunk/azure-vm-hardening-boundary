#!/usr/bin/env bash
# Enhanced CIS Level 1 hardening with OpenSCAP and basic custom hardening

set -euo pipefail

LOG="/var/log/hardening.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Starting enhanced CIS Level 1 hardening..."

# Update package lists and install OpenSCAP tools
apt-get update
apt-get install -y openscap-scanner scap-security-guide

OSCAP_PROFILE="xccdf_org.ssgproject.content_profile_cis"
OSCAP_CONTENT="/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml"

# Check if the SCAP content file exists
if [ ! -f "$OSCAP_CONTENT" ]; then
  echo "[ERROR] OSCAP content not found at $OSCAP_CONTENT"
  exit 1
fi

# Run pre-hardening OpenSCAP scan to assess current system state
echo "[INFO] Running pre-hardening OpenSCAP scan..."
oscap xccdf eval --profile "$OSCAP_PROFILE" --results pre_hardening_results.xml "$OSCAP_CONTENT"

# Run automatic remediation using OpenSCAP
echo "[INFO] Running automatic remediation..."
oscap xccdf eval --profile "$OSCAP_PROFILE" --remediate "$OSCAP_CONTENT"

# Apply additional custom hardening steps not covered by OpenSCAP

echo "[INFO] Applying additional custom hardening..."

# Example: Disable root SSH login for better security
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Example: Strengthen sysctl parameters to protect against IP spoofing
cat >> /etc/sysctl.d/99-custom.conf << EOF
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
sysctl --system

# Example: Enable firewall with default deny incoming and allow outgoing rules
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Run post-hardening OpenSCAP scan to verify the system state after remediation
echo "[INFO] Running post-hardening OpenSCAP scan..."
oscap xccdf eval --profile "$OSCAP_PROFILE" --results post_hardening_results.xml "$OSCAP_CONTENT"

echo "[INFO] Hardening complete. Reports saved as pre_hardening_results.xml and post_hardening_results.xml"

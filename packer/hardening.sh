#!/usr/bin/env bash
# Run CIS Level 1 hardening with OpenSCAP

set -euo pipefail

LOG="/var/log/hardening.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Starting CIS Level 1 hardening..."

apt-get update
apt-get install -y openscap-scanner scap-security-guide

OSCAP_PROFILE="xccdf_org.ssgproject.content_profile_cis"
OSCAP_CONTENT="/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml"

if [ ! -f "$OSCAP_CONTENT" ]; then
  echo "[ERROR] OSCAP content not found at $OSCAP_CONTENT"
  exit 1
fi

oscap xccdf eval \
  --profile "$OSCAP_PROFILE" \
  --results before_hardening.xml \
  "$OSCAP_CONTENT"

# TODO: Implement additional custom hardening steps here as needed

oscap xccdf eval \
  --profile "$OSCAP_PROFILE" \
  --results after_hardening.xml \
  "$OSCAP_CONTENT"

echo "[INFO] Hardening complete. Reports: before_hardening.xml, after_hardening.xml"
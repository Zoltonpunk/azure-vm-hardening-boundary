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
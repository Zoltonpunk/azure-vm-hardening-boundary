#!/usr/bin/env bash
# Remove Azure Agent for hardening

systemctl stop walinuxagent
apt-get remove -y walinuxagent
rm -rf /var/lib/waagent
#!/usr/bin/env bash
# Restrictive iptables rules for Boundary/Apache host
# Tailored to assessment requirements: Boundary + Apache reverse proxy + hardened VM

set -euo pipefail

IPTABLES_DIR="/etc/iptables"
RULES_FILE="${IPTABLES_DIR}/rules.v4"
TRUSTED_SSH_SUBNET="203.0.113.0/24"
BOUNDARY_API_PORT=9200     # Internal port Boundary listens on (proxied by Apache)
APACHE_HTTPS_PORT=443     # Port exposed externally for HTTPS reverse proxy

mkdir -p "$IPTABLES_DIR"

echo "[INFO] Flushing existing iptables rules..."
iptables -F
iptables -X
iptables -t nat -F

echo "[INFO] Setting default policies (DROP INPUT and FORWARD, ACCEPT OUTPUT)..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "[INFO] Allowing all loopback (lo) interface traffic..."
iptables -A INPUT -i lo -j ACCEPT

echo "[INFO] Allowing SSH from trusted subnet ($TRUSTED_SSH_SUBNET)..."
iptables -A INPUT -p tcp -s "$TRUSTED_SSH_SUBNET" --dport 22 -m conntrack --ctstate NEW -j ACCEPT

echo "[INFO] Allowing inbound HTTPS traffic on port $APACHE_HTTPS_PORT..."
iptables -A INPUT -p tcp --dport "$APACHE_HTTPS_PORT" -m conntrack --ctstate NEW -j ACCEPT

echo "[INFO] Allowing established and related incoming traffic..."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Optional: Allow ICMP (ping) for troubleshooting; comment out if undesired
echo "[INFO] Allowing ICMP packets (ping)..."
iptables -A INPUT -p icmp -j ACCEPT

# Optional: Log dropped packets at a rate limit to avoid flooding logs
echo "[INFO] Adding rate-limited logging for dropped packets..."
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

echo "[INFO] Saving iptables rules to $RULES_FILE..."
iptables-save > "$RULES_FILE"

echo "[SUCCESS] Restrictive firewall rules applied."

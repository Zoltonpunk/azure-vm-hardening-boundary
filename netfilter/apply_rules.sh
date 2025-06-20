#!/usr/bin/env bash
# Restrictive iptables rules for Boundary/Apache host

set -euo pipefail

mkdir -p /etc/iptables

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F

# Default policy: deny everything
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow inbound SSH from specific IP(s) - adjust IP accordingly
iptables -A INPUT -p tcp -s 203.0.113.0/24 --dport 22 -j ACCEPT

# Allow inbound HTTPS to Apache from anywhere (or restrict if desired)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow established and related incoming traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Optional: allow ICMP (ping)
iptables -A INPUT -p icmp -j ACCEPT

# Optional: log dropped packets (rate-limited)
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Save rules
iptables-save > /etc/iptables/rules.v4

echo "Restrictive firewall rules applied."

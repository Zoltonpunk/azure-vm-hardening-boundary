#!/usr/bin/env bash
# Restrictive iptables rules for Boundary/Apache host

set -e

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F

# Default policy: deny everything
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow inbound SSH (optional, restrict as needed)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow inbound HTTPS to Apache (from anywhere or restrict to specific IPs)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Save rules (Ubuntu-specific)
iptables-save > /etc/iptables/rules.v4

echo "Restrictive firewall rules applied."
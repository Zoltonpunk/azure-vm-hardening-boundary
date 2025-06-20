# Netfilter (Firewall) Rules

This directory contains scripts to set up restrictive firewall rules for the Boundary/Apache VM.

- `apply_rules.sh` — Apply iptables or nftables rules to only allow required inbound/outbound connections.
- Rules should restrict:
  - Inbound API/authentication ports only (e.g., 443 for Apache, only from trusted sources)
  - Outbound to necessary services only
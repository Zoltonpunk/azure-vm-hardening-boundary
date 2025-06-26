# Boundary & Apache Setup

This directory contains scripts and configuration for:
- Installing and configuring HashiCorp Boundary (controller and worker) on a single VM
- Setting up user authentication and a dummy HTTPS target
- Configuring Apache as a restrictive reverse proxy

## Setup Steps

1. Run `install_boundary.sh` to install HashiCorp Boundary (controller + worker) and iptables-persistent for firewall rules persistence
2. Run `setup_apache_proxy.sh` to install Apache, generate self-signed TLS, and set up the reverse proxy.
3. Run `setup_boundary_target.sh` to create a TCP target in Boundary pointing to the local Apache HTTPS server
4. Running `setup_boundary_user.sh` creates a password-based auth method and demo user in Boundary
5. Use `netfilter/` scripts to apply firewall rules.

See the details in each script for customization.
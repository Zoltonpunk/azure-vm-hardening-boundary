# Azure VM Hardening and Boundary Access Service

This repository contains code, configuration, and automation for:
- Building a hardened Ubuntu 22.04 Azure VM image with Packer
- Setting up a remote access service with Boundary and an Apache reverse proxy

## Structure

- `/packer/` — Packer templates, hardening scripts, and documentation
- `/boundary/` — Boundary configuration, startup scripts, and Apache reverse proxy setup
- `/netfilter/` — Netfilter (iptables/nftables) rules and scripts
- `.github/workflows/` — CI/CD automation using GitHub Actions
- `/docs/` — Reports, before/after hardening results, and explanations

## Workflow

1. Edit and maintain Packer build scripts and hardening logic in `/packer/`
2. Use GitHub Actions to automate image building and validation
3. Store custom Boundary and Apache setup scripts in `/boundary/`
4. Document security decisions and exceptions in `/docs/`
5. Use `/netfilter/` for restrictive firewall rule automation

## Getting Started

See [docs/quickstart.md](docs/quickstart.md) for instructions.
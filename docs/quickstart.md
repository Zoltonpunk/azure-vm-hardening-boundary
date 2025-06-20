# Quickstart

## Prerequisites

- Azure subscription
- Service Principal for Packer builds
- GitHub repository secrets for Azure credentials

## Build Hardened Image

1. Fork and clone this repository
2. Add your Azure credentials to GitHub Secrets
3. Push any changes—GitHub Actions will build and harden your image!

## Setup Boundary and Apache

See [../boundary/README.md](../boundary/README.md) for full instructions.

## Reviewing Results

- Hardening reports: `packer/before_hardening.xml`, `packer/after_hardening.xml`
- Customization docs: `docs/exceptions.md`
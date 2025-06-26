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

## Azure Credentials

You must create and provide the following Azure credentials for image builds:
- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID

Set these as [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) under your repository.

*Do not commit these secrets to your repo.*

## Reviewing Results

- Hardening reports: `docs/pre_hardening_results.xml`, `docs/post_hardening_results.xml`
- Customization docs: `docs/exceptions.md` *currently not present, can be added if required*

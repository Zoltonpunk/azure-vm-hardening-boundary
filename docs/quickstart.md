# Quickstart Guide: Hardened Ubuntu VM with Boundary

This guide walks you through building a hardened Ubuntu 22.04 image using Packer, setting up a local Boundary instance with Apache reverse proxy and TLS, and applying firewall rules for secure testing.

---

## 🔧 Prerequisites

- Microsoft Azure subscription
- `packer`, `az`, and `ssh` CLI tools
- Ubuntu 22.04 base image from Canonical
- Linux host for building/testing

---

## 🛠️ Step 1: Build Hardened Image with Packer

```bash
cd packer
packer init templates/
packer build -var-file=templates/variables.pkrvars.hcl templates/ubuntu2204-azure.pkr.hcl
```

Outputs an Azure-managed image with:
- OpenSCAP CIS Level 1 hardening
- Azure agent removed
- Apache, Boundary, and TLS pre-installed

📄 Reports:
- `../pre_hardening_results.xml`
- `../post_hardening_results.xml`

---

## 🔐 Step 2: Launch the VM

Create a VM in Azure using the newly built image. Ensure the following:
- Assign static IP or DNS
- Enable serial console access for debugging
- Set correct network security group (NSG) rules

---

## 🌐 Step 3: Apache + Boundary Setup

SSH into the VM and run the following:

```bash
cd boundary
sudo ./install_boundary.sh
sudo ./setup_apache_proxy.sh
sudo ./setup_boundary_user.sh
sudo ./setup_boundary_target.sh
```

Creates:
- Boundary controller & worker (same host)
- Apache TLS proxy on `https://boundary.local`
- Single user login (password auth)
- Dummy HTTPS website as target (`localhost`)

---

## 🔒 Step 4: Apply Firewall Rules

```bash
cd ../netfilter
sudo ./apply_rules.sh
```

Netfilter rules ensure:
- Only essential inbound connections (HTTPS, API)
- All other traffic dropped

---

## 🧪 Step 5: Test Access

1. Add `boundary.local` to your `/etc/hosts`:
   ```
   <vm-public-ip> boundary.local
   ```
2. Access `https://boundary.local` in browser
3. Log in with the configured Boundary user
4. Connect to dummy target via Boundary desktop or CLI

---

## Azure Credentials

You must create and provide the following Azure credentials for image builds:
- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID

Set these as [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) under your repository.

*Do not commit these secrets to your repo.*

---

## Reviewing Results

- Hardening reports: `docs/pre_hardening_results.xml`, `docs/post_hardening_results.xml`
- Customization docs: `docs/exceptions.md` *currently not present, can be added if required*

---

## 📌 Notes

- Apache uses a self-signed TLS cert generated during image build (`generate_cert.sh`)
- All services run locally (intended for demo/testing purposes)
- `boundary.hcl` and logs can be reviewed for debugging

---

## ✅ Done!
You’ve now built a fully hardened, self-contained Boundary access setup with TLS, firewall rules, and image security controls.


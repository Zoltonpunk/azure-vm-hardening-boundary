Azure VM Hardening & Boundary Access Setup

This repository implements a secure remote access solution using HashiCorp Boundary, Apache reverse proxy, TLS, and Packer-hardened Ubuntu 22.04 images.


---

📁 Directory Structure

packer/               # Packer image builder,setup,agent removal and hardening scripts, dummy HTTPS, TLS certificate generation
boundary/             # Boundary configuration and setup, Apache reverse proxy
netfilter/            # Iptables (netfilter) firewall rules
openscap-reports/     # OpenSCAP hardening reports (before/after)
docs/                 # Quickstart and documentation


---

✅ Steps to Reproduce

1. Build and Harden Ubuntu Image with Packer

cd packer/

Customize variables in ubuntu2204-azure.pkr.hcl if needed

packer init templates/

packer build -var-file="variables.pkrvars.hcl" templates/

2. Deploy the Image in Azure

Deploy the image manually or via Terraform/CLI. SSH into the VM.

3. Apply OpenSCAP Hardening (CIS Level 1)

sudo bash packer/scripts/hardening.sh

Place the reports in openscap-reports/.

4. Remove Azure Agent

sudo bash packer/scripts/remove-azure-agent.sh

Note: This disables Azure-specific telemetry and VM extensions.


---

🔐 Secure Boundary + Apache Reverse Proxy

5. Generate TLS Certificates

sudo bash scripts/generate_cert.sh

6. Start Dummy HTTPS Apache Service

sudo bash scripts/start_dummy_https.sh

Apache will serve a test page on https://localhost:443.

7. Install & Configure Boundary

sudo bash boundary/install_boundary.sh

sudo boundary dev -config boundary.hcl

8. Create Boundary User

bash scripts/setup_boundary_user.sh

9. Create Boundary Target

bash scripts/setup_boundary_target.sh


---

🧱 Apply Netfilter Rules

sudo bash netfilter/apply_rules.sh

This script applies strict iptables rules allowing only necessary traffic.


---

🧪 Test Access Flow

Authenticate via Boundary using CLI with demo:demo123

Connect to the dummy HTTPS service via target



---

📎 Notes

Reports are located in openscap-reports/

TLS certificates are stored in /etc/apache2/ssl/

For production, replace dummy certs with real CA-signed ones



---

📄 License

MIT License

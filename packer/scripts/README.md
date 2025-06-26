🔒 Azure Linux Agent Removal (Security Hardening)

As part of the CIS Level 1 hardening process, the Azure Linux Agent (walinuxagent) has been intentionally removed from the image.

✅ Why is it removed?

The Azure Linux Agent performs automation tasks like:

Injecting SSH public keys during deployment

Managing VM extensions

Providing diagnostic and monitoring integration


However, it can be a potential attack surface in hardened environments. Removing it:

Reduces exposure to privilege escalation vectors

Prevents automatic script or extension execution

Forces explicit control over VM initialization and access


⚠️ What are the consequences?

Without the agent:

Azure will not be able to inject your SSH key automatically

You will not be able to use Azure VM Extensions

Hostname and diagnostics integration may not work

You must handle provisioning manually (e.g., with cloud-init or Packer)


🔧 How to connect to the VM

Since Azure cannot inject SSH keys automatically, ensure you:

Use Packer’s ssh_username and a file provisioner to pre-copy your SSH key

Or use cloud-init with a static SSH key

Or define a static user/password combo for test purposes (not recommended in production)


🛠 Boot Stability

After removing the agent, the initramfs has been regenerated to ensure clean boot behavior:

update-initramfs -u

This ensures that removed agent components (e.g., device rules or services) are not referenced during the next boot cycle.

📋 OpenSCAP Exceptions

During the hardening process, the CIS Level 1 Workstation profile was applied. However, a few rules were intentionally skipped due to practical constraints:

Rule ID	Reason for Exception	Risk Assessment

xccdf_org.ssgproject.content_rule_no_usb_devices	USB support was kept for debug and manual file copy	Minimal if physical access is restricted
disable_ctrlaltdel_burstaction	Left enabled for dev/test VM recovery	Low – only affects physical console


📁 Full before/after reports can be found in openscap-reports/.

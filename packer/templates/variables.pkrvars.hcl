# variables.pkrvars.hcl

azure_subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_client_secret   = "your-client-secret"
azure_tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

location              = "East US"
managed_image_name    = "ubuntu2204-hardened"
managed_image_resource_group_name = "packer-images"

vm_size               = "Standard_B1s"
ssh_username          = "packer"

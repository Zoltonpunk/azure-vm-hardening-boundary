{
  "variables": {
    "azure_subscription_id": "",
    "azure_client_id": "",
    "azure_client_secret": "",
    "azure_tenant_id": ""
  },
  "builders": [
    {
      "type": "azure-arm",
      "subscription_id": "{{user `azure_subscription_id`}}",
      "client_id": "{{user `azure_client_id`}}",
      "client_secret": "{{user `azure_client_secret`}}",
      "tenant_id": "{{user `azure_tenant_id`}}",
      "managed_image_resource_group_name": "myResourceGroup",
      "managed_image_name": "hardened-ubuntu2204",
      "os_type": "Linux",
      "image_publisher": "Canonical",
      "image_offer": "0001-com-ubuntu-server-jammy",
      "image_sku": "22_04-lts-gen2",
      "location": "East US",
      "vm_size": "Standard_DS1_v2"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "script": "hardening.sh"
    },
    {
      "type": "shell",
      "script": "remove-azure-agent.sh"
    }
  ]
}
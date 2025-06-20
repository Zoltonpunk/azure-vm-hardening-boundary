packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 1.0.0"
    }
  }
}

variable "arm_subscription_id" {}
variable "arm_client_id" {}
variable "arm_client_secret" {}
variable "arm_tenant_id" {}
variable "resource_group" { default = "myResourceGroup" }
variable "image_name"     { default = "hardened-ubuntu2204" }
variable "location"       { default = "East US" }
variable "vm_size"        { default = "Standard_DS1_v2" }

source "azure-arm" "ubuntu2204" {
  subscription_id                = var.arm_subscription_id
  client_id                      = var.arm_client_id
  client_secret                  = var.arm_client_secret
  tenant_id                      = var.arm_tenant_id
  managed_image_resource_group_name = var.resource_group
  managed_image_name             = var.image_name
  os_type                        = "Linux"
  image_publisher                = "Canonical"
  image_offer                    = "0001-com-ubuntu-server-jammy"
  image_sku                      = "22_04-lts-gen2"
  location                       = var.location
  vm_size                        = var.vm_size
}

build {
  sources = ["source.azure-arm.ubuntu2204"]

  provisioner "shell" {
    script = "../scripts/setup.sh"
  }
}

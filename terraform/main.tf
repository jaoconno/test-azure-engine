terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "azurerm_image" "golden_image" {
  name                = var.golden_image_name
  resource_group_name = var.golden_image_resource_group_name
}

data "azurerm_resource_group" "infra_app_rg" {
  name     = var.resource_group
}

resource "random_password" "password" {
  length = 16
  special = true
}

resource "azurerm_windows_virtual_machine_scale_set" "infra_app_vmss" {
  name                = "${var.deployment_id}-vmss"
  resource_group_name = data.azurerm_resource_group.infra_app_rg.name
  location            = data.azurerm_resource_group.infra_app_rg.location
  sku                 = "Standard_F2"
  instances           = var.instance_count
  admin_username      = "azureuser"
  admin_password      = random_password.password.result

  source_image_id = data.azurerm_image.golden_image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.deployment_id}-nic"
    primary = true

    ip_configuration {
      name      = "${var.deployment_id}-NicConfiguration"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  tags = {
    project = "infra-app"
  }
}

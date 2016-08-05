provider "azurerm" {}

resource "azurerm_resource_group" "test" {
  name     = "NDCSydneyResourceGroup"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "test" {
  name                = "NDCVirtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "NDCPublicSubnet"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_storage_account" "test" {
  name                = "ndcsydneysa"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${var.location}"
  account_type        = "Standard_LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  storage_account_name  = "${azurerm_storage_account.test.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine_scale_set" "linux" {
  name = "ndc-sydney-linux-scale-set"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name = "Standard_A0"
    tier = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username = "myadmin"
    admin_password = "Passwword1234"
  }

  network_profile {
      name = "NDCSydneyLinuxNetworkProfile"
      primary = true
      ip_configuration {
        name = "PublicSubnet"
        subnet_id = "${azurerm_subnet.test.id}"
      }
  }

  storage_profile_os_disk {
    name = "osDiskProfile"
    caching       = "ReadWrite"
    create_option = "FromImage"
    vhd_containers = ["${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}"]
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "16.04.201604203"
  }
}






/*resource "azurerm_virtual_machine_scale_set" "windows" {
  name = "ndc-sydney-windows-scale-set"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name = "Standard_A0"
    tier = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username = "myadmin"
    admin_password = "Passwword1234"
  }

  network_profile {
      name = "NDCSydneyWindowsNetworkProfile"
      primary = true
      ip_configuration {
        name = "PublicSubnet"
        subnet_id = "${azurerm_subnet.test.id}"
      }
  }

  storage_profile_os_disk {
    name = "osDiskProfile"
    caching       = "ReadWrite"
    create_option = "FromImage"
    vhd_containers = ["${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}"]
  }

  storage_profile_image_reference {
       publisher = "MicrosoftWindowsServer"
       offer = "WindowsServer"
       sku = "2012-R2-Datacenter"
       version = "latest"
  }
}*/

variable "prefix" {
  default = "rancher"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resources"
  location = "South Central US"
}


resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "nsr-inbound" {
  name                        = "${var.prefix}-in-ports"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_ranges          = "*"
  destination_port_ranges     = "[22, 88, 443]"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

resource "azurerm_network_security_rule" "nsr-outbound" {
  name                        = "${var.prefix}-out-ports"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_ranges          = "*"
  destination_port_ranges     = "[22, 88, 443]"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/30"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "10.0.2.0/30"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_network_interface" "network_interface" {
  name                = "${var.prefix}-network_interface"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_virtual_machine" "server" {
  name                  = "${var.prefix}-server"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_D2_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true
  
  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-RAW"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "server-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "server"
    admin_username = "admin@123"
    admin_password = "admin@123"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "DevOps / IaC / Test"
  }

}

resource "azurerm_virtual_machine" "host" {
  name                  = "${var.prefix}-host"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_D2_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-RAW"
    version   = "latest"
  }

  storage_os_disk {
    name              = "host-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name  = "server"
    admin_username = "admin@123"
    admin_password = "admin@123"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  
  }
  
  tags = {
    environment = "DevOps / IaC / Test"
  }

}


resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}_resources"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}_network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}_subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "public_ip_server" {
  name                = "${var.prefix}_public_ip_server"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"

  tags = {
    environment = "DevOps / IaC / Test"
  }
}

resource "azurerm_public_ip" "public_ip_host" {
  name                = "${var.prefix}_public_ip_host"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"

  tags = {
    environment = "DevOps / IaC / Test"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}_nsg"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "nsr_inbound" {
  name                        = "${var.prefix}_in_ports"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22","80","443","2376","2379","2380","8472","4789","6443","6783","9099","10250"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

resource "azurerm_network_security_rule" "nsr_outbound" {
  name                        = "${var.prefix}_out_ports"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22","80","443","2376","2379","2380","8472","4789","6443","6783","9099","10250"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

resource "azurerm_network_interface" "network_interface_server" {
  name                = "${var.prefix}_network_interface_server"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.prefix}_ip_configuration_server"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${cidrhost(azurerm_subnet.subnet.address_prefix, 5)}"
    public_ip_address_id          = "${azurerm_public_ip.public_ip_server.id}"
  }
}

resource "azurerm_network_interface" "network_interface_host" {
  name                = "${var.prefix}_network_interface_host"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.prefix}_ip_configuration_host"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${cidrhost(azurerm_subnet.subnet.address_prefix, 6)}"
    public_ip_address_id          = "${azurerm_public_ip.public_ip_host.id}"
  }
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_virtual_machine" "server" {
  name                  = "${var.prefix}_server"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.network_interface_server.id}"]
  vm_size               = "Standard_D2_v3"
  
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true
  
  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-RAW"
    version   = "7.6.2019062120"
  }
  
  storage_os_disk {
    name              = "server_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name  = "rancher"
    admin_username = "${var.server_admin_user}"
    admin_password = "${var.server_admin_pass}"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  tags = {
    environment = "DevOps / IaC / Test"
  }
  
}

resource "azurerm_virtual_machine" "host" {
  name                  = "${var.prefix}_host"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.network_interface_host.id}"]
  vm_size               = "Standard_D2_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-RAW"
    version   = "7.6.2019062120"
  }

  storage_os_disk {
    name              = "host_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "rancher"
    admin_username = "${var.host_admin_user}"
    admin_password = "${var.host_admin_pass}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "DevOps / IaC / Test"
  }

}

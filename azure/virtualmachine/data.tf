data "azurerm_public_ip" "data_public_ip_server" {
  name                = "${azurerm_public_ip.public_ip_server.name}"
  resource_group_name = "${azurerm_virtual_machine.server.resource_group_name}"
}

data "azurerm_public_ip" "data_public_ip_host" {
  name                = "${azurerm_public_ip.public_ip_host.name}"
  resource_group_name = "${azurerm_virtual_machine.host.resource_group_name}"
}
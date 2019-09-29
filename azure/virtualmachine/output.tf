output "public_ip_address_server" {
  value = "${data.azurerm_public_ip.data_public_ip_server.ip_address}"
}


output "public_ip_address_host" {
  value = "${data.azurerm_public_ip.data_public_ip_host.ip_address}"
}
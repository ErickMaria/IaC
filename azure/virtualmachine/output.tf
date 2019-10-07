output "public_ip_address_server" {
  value = "${data.azurerm_public_ip.data_public_ip_server.ip_address}"
}

output "server_user"{
  value = "${var.server_admin_user}"
}

output "server_pass" {
  value = "${var.server_admin_pass}"
}

output "public_ip_address_host" {
  value = "${data.azurerm_public_ip.data_public_ip_host.ip_address}"
}

output "host_user"{
  value = "${var.host_admin_user}"
}

output "host_pass" {
  value = "${var.host_admin_pass}"
}


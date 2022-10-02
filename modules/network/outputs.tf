output "subnet_id" {
  value = azurerm_subnet.vmss.id
}

output "net_id" {
  value = azurerm_virtual_network.vmss.id
}


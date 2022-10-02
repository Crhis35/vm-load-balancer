resource "azurerm_virtual_network" "vmss" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet" "vmss" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Web"]
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.vmss.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}

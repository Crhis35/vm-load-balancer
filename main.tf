resource "azurerm_resource_group" "resource_group" {
  name     = var.rg-name
  location = var.location
}


resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

module "network" {
  source = "./modules/network"
  resource_group = {
    name     = azurerm_resource_group.resource_group.name,
    location = azurerm_resource_group.resource_group.location,
  }
}
module "database" {
  source    = "./modules/database"
  subnet_id = module.network.subnet_id
  resource_group = {
    name     = azurerm_resource_group.resource_group.name,
    location = azurerm_resource_group.resource_group.location,
  }
  depends_on = [
    azurerm_resource_group.resource_group,
    module.network
  ]
}

module "vm-1" {
  source    = "./modules/vm"
  subnet_id = module.network.subnet_id
  net_id    = module.network.net_id

  resource_group = {
    name     = azurerm_resource_group.resource_group.name,
    location = azurerm_resource_group.resource_group.location,
  }
  depends_on = [
    azurerm_resource_group.resource_group,
    module.network
  ]
}

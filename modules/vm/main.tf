resource "azurerm_network_interface" "vm_interface" {
  for_each            = toset(var.vm_name)
  name                = each.value
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}
resource "azurerm_availability_set" "app_set" {
  name                         = "app-set"
  location                     = var.resource_group.location
  resource_group_name          = var.resource_group.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3

}
resource "azurerm_linux_virtual_machine" "vmss" {
  for_each                        = toset(var.vm_name)
  name                            = each.value
  location                        = var.resource_group.location
  resource_group_name             = var.resource_group.name
  admin_username                  = each.value
  admin_password                  = var.admin_password
  size                            = "Standard_B1ls"
  disable_password_authentication = false
  availability_set_id             = azurerm_availability_set.app_set.id

  network_interface_ids = [
    azurerm_network_interface.vm_interface[each.key].id
  ]



  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_public_ip" "load_ip" {
  name                = var.ip_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "vm_balancer" {
  name                = var.lb_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.load_ip.id
  }
  depends_on = [
    azurerm_public_ip.load_ip
  ]
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  name            = "BackEndAddressPool"
  loadbalancer_id = azurerm_lb.vm_balancer.id
}

resource "azurerm_lb_backend_address_pool_address" "vm_address" {
  for_each                = toset(var.vm_name)
  name                    = each.value
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
  virtual_network_id      = var.net_id
  ip_address              = azurerm_network_interface.vm_interface[each.key].private_ip_address

}


resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id = azurerm_lb.vm_balancer.id
  name            = "ssh-running-probe"
  port            = var.application_port
  protocol        = "Tcp"
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.vm_balancer.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "frontend-ip"
  probe_id                       = azurerm_lb_probe.vmss.id
}

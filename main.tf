resource "azurerm_resource_group" "default" {
  name     = var.name
  location = "West Europe"
}

resource "azurerm_virtual_network" "default" {
  name                = var.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
  name                 = var.name
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "default" {
  name                = var.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "default" {
  name                = var.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.default.id
  }
}

resource "azurerm_lb_backend_address_pool" "default" {
  name            = var.name
  loadbalancer_id = azurerm_lb.default.id
}

resource "azurerm_lb_probe" "default" {
  name                = var.name
  resource_group_name = azurerm_resource_group.default.name
  loadbalancer_id     = azurerm_lb.default.id
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.default.name
  loadbalancer_id                = azurerm_lb.default.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.default.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.default.id
}

data "local_file" "cloudinit" {
  filename = "${path.module}/cloud_config"
}

resource "azurerm_linux_virtual_machine_scale_set" "default" {
  name                = var.name
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "Standard_F2"
  instances           = var.instances
  admin_username      = "adminuser"

  upgrade_mode    = "Rolling"
  health_probe_id = azurerm_lb_probe.default.id
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  custom_data = base64encode(data.local_file.cloudinit.content)

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "default"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.default.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.default.id]
      public_ip_address {
        name = "public-ip"
      }
    }
  }
}

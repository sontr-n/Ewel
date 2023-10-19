resource "azurerm_virtual_network" "librechat_network" {
  name                = var.network_name
  address_space       = ["172.26.129.0/25"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "librechat_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.librechat_network.name
  address_prefixes     = ["172.26.129.0/28"]

  service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.Web"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

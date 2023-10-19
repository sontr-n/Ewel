locals {
  cosmosdb_ip_range_azure = [
    "104.42.195.92",
    "40.76.54.131",
    "52.176.6.30",
    "52.169.50.45",
    "52.187.184.26"
  ]
}


resource "azurerm_cosmosdb_account" "librechat" {
  name                      = var.cosmodb_name
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  offer_type                = "Standard"
  kind                      = "MongoDB"
  enable_automatic_failover = false
  enable_free_tier          = var.use_cosmosdb_free_tier
  ip_range_filter           = "${join(",",local.cosmosdb_ip_range_azure)}"
  mongo_server_version      = 4.2  

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.this.location
    failover_priority = 0
  }
  capabilities {
    name = "MongoDBv3.4"
  }
  capabilities {
    name = "EnableServerless"
  }
  capabilities {
    name = "EnableMongo"
  }
  
  virtual_network_rule {
    id = azurerm_subnet.librechat_subnet.id
  }

  # enable_multiple_write_locations = false
  is_virtual_network_filter_enabled = true
  public_network_access_enabled = true
}

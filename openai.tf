module "openai" {
  account_name        = "${var.openai_name}"
  source              = "Azure/openai/azurerm"
  version             = "0.1.1"
  resource_group_name = var.resource_group_name
  location            = azurerm_resource_group.this.location
  public_network_access_enabled = true
  sku_name            = "S0"


  deployment = {
    "chat_model" = {
      name          = "gpt-35-turbo"
      model_format  = "OpenAI"
      model_name    = "gpt-35-turbo"
      model_version = "0613"
      scale_type    = "Standard"
    },
    "embedding_model" = {
      name          = "text-embedding-ada-002"
      model_format  = "OpenAI"
      model_name    = "text-embedding-ada-002"
      model_version = "2"
      scale_type    = "Standard"
    }
  }
  depends_on = [
    azurerm_resource_group.this
  ]
}
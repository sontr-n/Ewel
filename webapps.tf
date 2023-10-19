data "azurerm_client_config" "current" {
}

resource "azuread_application" "webapp_authen" {
  display_name      = "ChatGPT_authen"
  owners            = [data.azurerm_client_config.current.object_id]

  web {
    homepage_url  = "https://${var.webapp_host_name}.azurewebsites.net"
    logout_url    = "https://${var.webapp_host_name}.azurewebsites.net/logout"
    redirect_uris = ["https://${var.webapp_host_name}.azurewebsites.net/.auth/login/aad/callback"]

    implicit_grant {
    id_token_issuance_enabled = true
    }
  }
}

resource "azurerm_service_plan" "librechat" {
  name                = var.service_plan_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"

  sku_name = var.app_service_sku_name
}

resource "azurerm_linux_web_app" "librechat" {
  name                          = var.webapp_host_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  service_plan_id               = azurerm_service_plan.librechat.id
  public_network_access_enabled = true
  https_only                    = true

  site_config {
    minimum_tls_version = "1.2"

  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
    application_logs {
      file_system_level = "Information"
    }
  }

  auth_settings_v2 {
    auth_enabled            = true
    default_provider        = "azureactivedirectory"
    require_authentication  = true
    require_https           = true
    unauthenticated_action   = "RedirectToLoginPage"
    forward_proxy_convention = "NoProxy"

    active_directory_v2 {
      client_id                   = azuread_application.webapp_authen.application_id
      tenant_auth_endpoint        = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name  = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    }

    login {
      token_store_enabled = true
    }
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
    HOST                     = "0.0.0.0"
    MONGO_URI                = azurerm_cosmosdb_account.librechat.connection_strings[0]
    MEILI_MASTER_KEY   = random_string.meilisearch_master_key.result
    MEILI_HOST         = "${azurerm_linux_web_app.meilisearch.name}.azurewebsites.net"
    SEARCH             = true
    MEILI_NO_ANALYTICS = true
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = ""

    APP_TITLE = var.webapp_host_name

    AZURE_API_KEY                                = module.openai.openai_primary_key
    AZURE_OPENAI_API_INSTANCE_NAME               = split("//", split(".", module.openai.openai_endpoint)[0])[1]
    AZURE_OPENAI_API_DEPLOYMENT_NAME             = "gpt-35-turbo"
    AZURE_OPENAI_API_VERSION                     = "2023-05-15"
    AZURE_OPENAI_API_COMPLETIONS_DEPLOYMENT_NAME = "gpt-35-turbo"
    AZURE_OPENAI_API_EMBEDDINGS_DEPLOYMENT_NAME  = "text-embedding-ada-002"

    CREDS_KEY = random_string.creds_key.result
    CREDS_IV  = random_string.creds_iv.result

    JWT_SECRET    = random_string.jwt_secret.result
    JWT_REFRESH_SECRET    = random_string.jwt_refresh_secret.result
    DOMAIN_SERVER = "http://localhost:3080"
    DOMAIN_CLIENT = "http://localhost:3080"

    VITE_SHOW_GOOGLE_LOGIN_OPTION = false
    ALLOW_REGISTRATION            = true
    ALLOW_SOCIAL_REGISTRATION     = false

    SESSION_EXPIRY = (1000 * 60 * 60 * 24) * 7

    DOCKER_REGISTRY_SERVER_URL          = "https://index.docker.io"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_ENABLE_CI                    = false
    WEBSITES_PORT                       = 80
    PORT                                = 80
    DOCKER_CUSTOM_IMAGE_NAME            = "ghcr.io/danny-avila/librechat-dev-api:latest"
    NODE_ENV                            = "production"
  }
  virtual_network_subnet_id = azurerm_subnet.librechat_subnet.id

  depends_on = [azurerm_linux_web_app.meilisearch, azurerm_cosmosdb_account.librechat, module.openai]
}

#TODO: privately communicate between librechat and meilisearch, right now it is via public internet
resource "azurerm_linux_web_app" "meilisearch" {
  name                = var.search_host_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.librechat.id

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    MEILI_MASTER_KEY   = random_string.meilisearch_master_key.result
    MEILI_NO_ANALYTICS = true

    DOCKER_REGISTRY_SERVER_URL          = "https://index.docker.io"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_ENABLE_CI                    = false
    WEBSITES_PORT                       = 7700
    PORT                                = 7700
    DOCKER_CUSTOM_IMAGE_NAME            = "getmeili/meilisearch:latest"
  }

  site_config {
    always_on = "true"
    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.librechat_subnet.id
      priority                  = 100
      name                      = "Allow from LibreChat subnet"
      action                    = "Allow"
    }
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
    application_logs {
      file_system_level = "Information"
    }
  }
} 

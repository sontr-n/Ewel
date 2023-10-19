variable "location" {
  description = "The location where all resources will be deployed"
  default     = "japaneast"
}

variable "app_title" {
  description = "The title that librechat will display"
  default     = "librechat"
}

variable "app_service_sku_name" {
  description = "size of the VM that runs the librechat app. F1 is free but limited to 1h per day."
  default = "F1"
}

variable "mongo_uri" {
  description = "Connection string for the mongodb"
  default = ""
  sensitive = true
}

variable "use_cosmosdb_free_tier" {
  description = "Flag to enable/disable free tier of cosmosdb. This needs to be false if another instance already uses free tier."
  type = bool
  default = true
}

variable "webapp_host_name" {
  description = "Name hosted web app services"
}

variable "search_host_name" {
  description = "Name hosted web app search services"
}

variable "openai_name" {
  description = "Name OpenAI resource"
}

variable "cosmodb_name" {
  description = "Name CosmosDB resource"
}

variable "service_plan_name" {
  description = "Name service plan resource"
}

variable "resource_group_name" {
  description = "Name resource group"
}

variable "network_name" {
  description = "network name"
}

variable "subnet_name" {
  description = "subnet name"
}

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether public network access is allowed for the Azure OpenAI Service"
  type = bool
  default = false
}
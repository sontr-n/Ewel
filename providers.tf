# Azure provider version
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.7.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}

provider "azuread" {}
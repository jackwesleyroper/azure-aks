terraform {
  required_version = "1.10.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# provider "azurerm" {
#   features {}
#   skip_provider_registration = false
#   alias                      = "management_sub"
#   subscription_id            = var.config.management_sub_id
# }

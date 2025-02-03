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

  backend "azurerm" {
    resource_group_name   = "tf-rg"
    storage_account_name  = "jacktfstatesa"
    container_name        = "terraform"
    key                   = "azure-aks/001_resource_groups.tfstate"
  }
}

provider "azurerm" {
  features {}
}

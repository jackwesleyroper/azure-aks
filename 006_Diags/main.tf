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
    key      = "azure-aks/dev/006_Diags.tfstate"
    use_oidc = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

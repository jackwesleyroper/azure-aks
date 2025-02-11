terraform {
  required_version = "=1.2.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
  }

  backend "azurerm" {
    key      = "azure-aks/dev/007_Containers.tfstate"
    use_oidc = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
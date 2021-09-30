# Configure the Azure provider
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.78.0"
    }
    hashicorp = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

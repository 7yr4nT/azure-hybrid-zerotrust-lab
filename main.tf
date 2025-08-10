# Description: Main Terraform configuration file.
# It sets up the Azure provider and creates the primary resource group.

# Configures the required providers for this Terraform project.
# We specify the azurerm provider from HashiCorp to interact with Azure.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configures the Azure provider itself.
# It will use the credentials from your 'az login' session.
# We add the 'skip_provider_registration' flag to prevent concurrent write errors.
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Creates a new Resource Group in Azure.
# A resource group is a container that holds related resources for an Azure solution.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

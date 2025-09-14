terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"     # RG for state
    storage_account_name = "tfstateaccount123"      # must be globally unique
    container_name       = "tfstate"                # blob container
    key                  = "infra.terraform.tfstate" # state file name
  }
}

provider "azurerm" {
  features {}
}

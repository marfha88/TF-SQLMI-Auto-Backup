# Configure Terraform to set the required AzureRM provider
# version and features{} block.
# Configure the AzureRM backend to store the Terraform state file in an Azure Storage Account.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.98.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "your resource group name"
    storage_account_name = "your storage account name"
    container_name       = "your container name"
    key                  = "your key" // Example: aa-sqlmi-backup.tfstate
    subscription_id      = "your subscription id"
  }
}

provider "azurerm" {
  subscription_id = "your subscription id"
  features {}
}

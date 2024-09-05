# Variables to customize deployment
data "azurerm_client_config" "current" {}


variable "tags" {
  type        = map(any)
  description = "Tags for VMs"
  default = {
    environment = "your-environment"
    source      = "terraform"
    createdby   = "example"
    repo        = "your-repo"
    createddate = "todays-date"
  }
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Standard Datacenter location"
}

variable "Runbook_Name" {
  description = "The name of the runbook"
  type        = string
  default     = "sqlmi-backup"  
}

variable "sub_Shared_ID" {
  type = string
  default = "your subscription id"
}
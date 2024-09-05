
#Resource Group#
################

resource "azurerm_resource_group" "rg-aa-sqlmi-backup" {
  name     = "rg-aa-sqlmi-backup"
  location = var.location
}

resource "azurerm_automation_account" "aa-sqlmi-backup" {
  name                = "aa-sqlmi-backup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-aa-sqlmi-backup.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

data "local_file" "runbook" {
  filename = "${path.module}/Powershell/sqlmi.ps1"
}

resource "azurerm_automation_runbook" "sqlmi-backup" {
  name                    = var.Runbook_Name
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg-aa-sqlmi-backup.name
  automation_account_name = azurerm_automation_account.aa-sqlmi-backup.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This runbook is used to backup SQL Managed Instance"
  runbook_type            = "PowerShell72"
  content                 = data.local_file.runbook.content
  tags                    = var.tags
}


resource "azurerm_automation_schedule" "everyday_run" {
  name                    = "everyday_run"
  resource_group_name     = azurerm_resource_group.rg-aa-sqlmi-backup.name
  automation_account_name = azurerm_automation_account.aa-sqlmi-backup.name
  frequency               = "Day"
  interval                = 1
  timezone                = "America/New_York" // Change this to your timezone
  start_time              = formatdate("YYYY-MM-DD'T'01:00:00Z", timeadd(timestamp(), "24h"))
  description             = "This schedule run one time every day and its linked to ${var.Runbook_Name}"
}

resource "azurerm_automation_job_schedule" "link_schedule" {
  resource_group_name     = azurerm_resource_group.rg-aa-sqlmi-backup.name
  automation_account_name = azurerm_automation_account.aa-sqlmi-backup.name
  schedule_name           = azurerm_automation_schedule.everyday_run.name
  runbook_name            = azurerm_automation_runbook.sqlmi-backup.name
}
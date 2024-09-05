
# ----------------------------------
# Automation Account
# ----------------------------------

# Automation Account get role Reader and Data Access on resource group
resource "azurerm_role_assignment" "aa_rg_rbac1" {
  scope                = var.sub_Shared_ID
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.aa-sqlmi-backup.identity[0].principal_id
}

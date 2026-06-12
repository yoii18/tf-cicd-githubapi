resource "azurerm_storage_account" "strgacct" {
  account_replication_type = "LRS"
  location                 = var.location
  name                     = ""
  resource_group_name      = ""
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"
  is_hns_enabled           = true
}

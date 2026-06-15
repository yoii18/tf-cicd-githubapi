resource "azurerm_data_factory" "adf" {
  location            = var.location
  name                = var.name
  resource_group_name = var.rgname

  identity {
    type = "SystemAssigned"
  }
}

resource "time_sleep" "time" {
  create_duration = "30s"
  depends_on      = [azurerm_data_factory.adf]
}

data "azuread_group" "storage_blob_group" {
  display_name     = var.groupname
  security_enabled = true
}

data "azuread_service_principal" "ad_sp" {
  object_id  = azurerm_data_factory.adf.identity[0].principal_id
  depends_on = [azurerm_data_factory.adf]
}

resource "azuread_group_member" "storage_blob_group_member_addition" {
  member_object_id = data.azuread_service_principal.ad_sp.object_id
  group_object_id  = data.azuread_group.storage_blob_group.object_id
}

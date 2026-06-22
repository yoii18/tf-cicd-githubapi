################ Data Sets ################

resource "azurerm_data_factory_custom_dataset" "rest_api_ds" {
  name            = "rest_api_ds"
  type            = "RestResource"
  data_factory_id = var.adf_id
  linked_service {
    name = azurerm_data_factory_linked_custom_service.name.name
  }
  type_properties_json = jsonencode({
    relativeUrl   = "users/yoii18"
    requestMethod = "GET"
    requestBody   = ""
  })
}

resource "azurerm_data_factory_custom_dataset" "adls_ds" {
  name            = "adls_ds"
  type            = "Json"
  data_factory_id = var.adf_id
  linked_service {
    name = azurerm_data_factory_linked_custom_service.adf_adls_ls.name
  }
  type_properties_json = jsonencode({
    location = {
      type       = "AzureBlobFSLocation"
      fileSystem = "staging"
      folderPath = "raw/data"
      fileName   = "data.json"
    }
    encodingName = "UTF-8"
  })
  schema_json = jsonencode([])
}


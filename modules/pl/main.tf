
################ Linked Services ################
resource "azurerm_data_factory_linked_custom_service" "name" {
  type = "RestService"
  name = "adf_rest_ls"
  type_properties_json = jsonencode({
    enableServerCertificateValidation = true
    url                               = "https://api.github.com/"
    authenticationType                = "Anonymous"
    headers = {
      Accept               = "application/vnd.github+json"
      X-GitHub-Api-Version = "2026-03-10"
    }
  })
  data_factory_id = var.adf_id
}

resource "azurerm_data_factory_linked_custom_service" "adf_adls_ls" {
  type = "AzureBlobFS"
  name = "adf_adls_ls"
  type_properties_json = jsonencode({
    url = "https://${var.strgname}.dfs.core.windows.net"
  })
  data_factory_id = var.adf_id
}

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

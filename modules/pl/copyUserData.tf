################ Pipeline ################

resource "azurerm_data_factory_pipeline" "copy_data_pl" {
  data_factory_id = var.adf_id
  name            = "copy_data_pl"
  activities_json = jsonencode([
    {
      name           = "Copy Data"
      type           = "Copy"
      dependsOn      = []
      userProperties = []
      typeProperties = {
        source = {
          type               = "RestSource"
          httpRequestTimeout = "00:05:00"
          requestMethod      = "GET"
        }
        sink = {
          type = "AzureBlobFSSink"
          storeSettings = {
            type = "AzureBlobFSWriteSettings"
          }
          formatSettings = {
            type = "JsonWriteSettings"
          }
        }
        enableStaging = false
      }
      inputs = [{
        referenceName = azurerm_data_factory_custom_dataset.rest_api_ds.name
        type          = "DatasetReference"
      }]
      outputs = [{
        referenceName = azurerm_data_factory_custom_dataset.adls_ds.name
        type          = "DatasetReference"
      }]
    }
  ])
}
